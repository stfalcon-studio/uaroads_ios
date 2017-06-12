//
//  RecordService.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/21/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import CoreLocation

final class RecordService {
    
    static let sharedInstance = RecordService()
    
    //================
    
    public let dbManager: RealmManager
    public let motionManager: MotionManager
    public let locationManager: LocationManager
    public let networkManager: NetworkManager
    
    var previousLocation: CLLocation?
    
    var onPit: ((_ pitValue: Double) -> ())?
    var onMotionStart: ((_ point: Double, _ filtered: Bool) -> ())?
    var onMotionStop: (() -> ())?
    var onLocation: (() -> ())?
    var onMotionCompleted: (() -> ())?
    var onSend: (() -> ())?
    
    private init() {
        dbManager = RealmManager()
        locationManager = LocationManager()
        motionManager = MotionManager()
        networkManager = NetworkManager.sharedInstance
        
        onPit = { [unowned self] pitValue in
            self.handleOnPitEvent(pitValue: pitValue)
        }
        
        locationManager.onLocationUpdate = { [unowned self] in
            self.handleUpdateLocationEvent()
        }
        
        onSend = { [unowned self] in
            self.handleOnSendEvent()
        }
        
        onMotionCompleted = { [unowned self] in
            self.handleMotionCompletedEvent()
        }
    }
    
    
    // MARK: Public funcs
    
    func startRecording() {
        locationManager.requestLocation()
        motionManager.startRecording()
    }
    
    func stopRecording() {
        locationManager.stopUpdatingLocation()
        onMotionStop?()
        motionManager.stopRecording()
    }
    
    func pauseRecording() {
        locationManager.stopUpdatingLocation()
        motionManager.pauseRecording()
    }
    
    func resumeRecording() {
        locationManager.requestLocation()
        motionManager.resumeRecording()
    }
    
    
    // MARK: Private funcs
    
    private func handleUpdateLocationEvent() {
        let manager = self.motionManager

        if let newLocation = locationManager.currentLocation {
            let pit = PitModel()
            pit.latitude = newLocation.coordinate.latitude
            pit.longitude = newLocation.coordinate.longitude
            pit.time = "\(Date().timeIntervalSince1970 * 1000)"
            pit.value = 0.0
            
            pit.tag = "cp"
            
            self.dbManager.update {
                manager.track?.pits.append(pit)
            }
            self.dbManager.add(manager.track)
            
            if let previous = self.previousLocation {
                
                let extraDistance = newLocation.distance(from: previous)
//                pl("distance = \(extraDistance)")
//                pl("track.distance before = \(manager.track!.distance)")
                self.dbManager.update {
                    manager.track?.distance += CGFloat(extraDistance)
//                    pl("track.distance = \(manager.track!.distance)")
                }
                self.dbManager.add(manager.track)
            }
            
            if newLocation.horizontalAccuracy <= 10 {
                if manager.maxSpeed < newLocation.speed {
                    manager.maxSpeed = newLocation.speed
                }
            }
            
            previousLocation = newLocation
        }
    }
    
    private func handleOnSendEvent() {
        AnalyticManager.sharedInstance.reportEvent(category: "System", action: "SendDataActivity Start")
        
        var sendingInProcess = false
        
        let pred = NSPredicate(format: "(status == 2) OR (status == 3)")
        let result = self.dbManager.objects(type: TrackModel.self)?.filter(pred)
        
        if sendingInProcess == false {
            if let result = result, result.count > 0 {
                sendingInProcess = true
                
                if let track = result.first {
                    self.dbManager.update {
                        track.status = TrackStatus.uploading.rawValue
                    }
                    
                    //prepare params for sending
                    let data64 = UARoadsSDK.encodePoints(Array(track.pits))
                    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
                    let params = [
                        "uid":NSUUID().uuidString,
                        "comment":track.title,
                        "routeId":track.trackID,
                        "data":data64 ?? "",
                        "app_ver":version as! String,
                        "auto_record":track.autoRecord ? "1" : "0",
                        "date":"\(track.date.timeIntervalSince1970)"
                        ] as [String : String]
                    
                    NetworkManager.sharedInstance.tryToSendData(params: params, handler: { val in
                        sendingInProcess = false
                        
                        if result.count > 1 && val  {
                            self.onSend?() //recursion
                        } else {
                            (UIApplication.shared.delegate as? AppDelegate)?.completeBackgroundTrackSending(val)
                        }
                        
                        self.dbManager.update {
                            if val == true {
                                track.status = TrackStatus.uploaded.rawValue
                            } else {
                                track.status = TrackStatus.waitingForUpload.rawValue
                            }
                        }
                    })
                }
            }
        }
        if !sendingInProcess {
            (UIApplication.shared.delegate as? AppDelegate)?.completeBackgroundTrackSending(false)
        }
        AnalyticManager.sharedInstance.reportEvent(category: "System", action: "sendDataActivity End")
    }
    
    private func handleMotionCompletedEvent() {
        //mark the end of the checkpoint
        let coordinate = locationManager.currentLocation?.coordinate
        let pit = PitModel()
        pit.time = "\(Date().timeIntervalSince1970 * 1000)"
        pit.latitude = coordinate?.latitude ?? 0.0
        pit.longitude = coordinate?.longitude ?? 0.0
        pit.tag = "cp"
        self.dbManager.update {
            self.motionManager.track?.pits.append(pit)
        }
        self.dbManager.add(self.motionManager.track)
        
        let pred = NSPredicate(format: "status == 0")
        let result = self.dbManager.objects(type: TrackModel.self)?.filter(pred)
        if let result = result, result.count > 0 {
            self.dbManager.update {
                for item in result {
                    if Date().timeIntervalSince(item.date) > 10 {
                        item.status = TrackStatus.waitingForUpload.rawValue
                    }
                }
            }
        }
    }
    
    private func handleOnPitEvent(pitValue: Double) {
        var pitN = Int(pitValue/0.3)
        if pitN > 5 {
            pitN = 5
        }
        let pitSound = "pit-\(pitN)"
        if SettingsManager.sharedInstance.enableSound == true {
            self.motionManager.playSound(pitSound)
        }
        
        let pit = PitModel()
        pit.value = pitValue
        pit.time = "\(Date().timeIntervalSince1970 * 1000)"
        pit.tag = "origin"
        
        self.dbManager.update {
            self.motionManager.track?.pits.append(pit)
        }
        self.dbManager.add(self.motionManager.track)
    }
}




