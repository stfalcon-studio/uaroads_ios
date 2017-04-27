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
    private init() {
        dbManager = RealmManager()
        locationManager = LocationManager()
        motionManager = MotionManager()
        networkManager = NetworkManager.sharedInstance
        
        onPit = { [unowned self] pitValue, location in
            var pitN = Int(pitValue/0.3)
            if pitN > 5 {
                pitN = 5
            }
            let pitSound = "pit-\(pitN)"
            if SettingsManager.sharedInstance.enableSound == true {
                self.motionManager.playSound(pitSound)
            }
            
            let pit = PitModel()
            pit.latitude = location?.latitude ?? 0.0
            pit.longitude = location?.longitude ?? 0.0
            pit.value = pitValue
            pit.time = "\(Date().timeIntervalSince1970 * 1000)"
            
            if location != nil {
                pit.tag = "cp"
            } else {
                pit.tag = "origin"
            }
            
            self.dbManager.update {
                self.motionManager.track?.pits.append(pit)
            }
            self.dbManager.add(self.motionManager.track)
        }
        
        locationManager.onLocationUpdate = { [unowned self] locations in
            let manager = self.motionManager
            
            if let newLocation = locations.first {
                manager.currentLocation = newLocation
                
                if manager.checkpoint == true {
                    //mark the begining of the checkpoint
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
                    
                    manager.checkpoint = false
                }
                
                var locationUpdate = false
                let lastDistance = newLocation.distance(from: manager.currentLocation!)
                let speed = lastDistance / newLocation.timestamp.timeIntervalSinceReferenceDate - manager.currentLocation!.timestamp.timeIntervalSinceReferenceDate
                
                if lastDistance > manager.currentLocation!.horizontalAccuracy && lastDistance > newLocation.horizontalAccuracy && speed < 70 {
                    self.dbManager.update {
                        manager.track?.distance += CGFloat(lastDistance)
                    }
                    self.dbManager.add(manager.track)
                    locationUpdate = true
                }
                
                if locationUpdate == true {
                    manager.delegate?.locationUpdated(location: manager.currentLocation!, trackDist: Double(manager.track!.distance))
                }
                
                // Calculate maximum speed for last 5 minutes
                if newLocation.horizontalAccuracy <= 10 {
                    if manager.maxSpeed < newLocation.speed {
                        manager.maxSpeed = newLocation.speed
                    }
                }
            }
        }
        
        onSend = { [unowned self] in
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
        
        onMotionCompleted = { [unowned self] coord in
            //mark the end of the checkpoint
            let pit = PitModel()
            pit.time = "\(Date().timeIntervalSince1970 * 1000)"
            pit.latitude = coord?.coordinate.latitude ?? 0.0
            pit.longitude = coord?.coordinate.longitude ?? 0.0
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
    }
    static let sharedInstance = RecordService()
 
    //================
    
    public let dbManager: RealmManager
    public let motionManager: MotionManager
    public let locationManager: LocationManager
    public let networkManager: NetworkManager
    
    var onPit: ((_ pitValue: Double, _ location: CLLocationCoordinate2D?) -> ())?
    var onMotionStart: ((_ point: Double, _ filtered: Bool) -> ())?
    var onMotionStop: (() -> ())?
    var onLocation: ((_ locations: [CLLocation]) -> ())?
    var onMotionCompleted: ((_ coord: CLLocation?) -> ())?
    var onSend: (() -> ())?
    
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
}









