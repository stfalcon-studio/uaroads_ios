//
//  RecordService.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/21/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import CoreLocation

class RecordService {
    private init() {
        dbManager = RealmManager()
        locationManager = LocationManager()
        motionManager = MotionManager()
        networkManager = NetworkManager.sharedInstance
        
        onPit = { [unowned self] currentPit in
            var pitN = Int(currentPit/0.3)
            if pitN > 5 {
                pitN = 5
            }
            let pitSound = "pit-\(pitN)"
            if SettingsManager.sharedInstance.enableSound == true {
                self.motionManager.playSound(pitSound)
            }
            
            let pit = PitModel()
            pit.latitude = self.locationManager.manager.location?.coordinate.latitude ?? 0.0
            pit.longitude = self.locationManager.manager.location?.coordinate.longitude ?? 0.0
            pit.value = currentPit
            pit.time = "\(Date().timeIntervalSince1970 * 1000)"
            pit.tag = "origin"
            
            RecordService.sharedInstance.dbManager.update {
                self.motionManager.track?.pits.append(pit)
            }
            RecordService.sharedInstance.dbManager.add(self.motionManager.track)
        }
        
        locationManager.onLocationUpdate = { [unowned self] locations in
            let manager = self.motionManager
            if let newLocation = locations.first {
                if let currentLocation = manager.currentLocation {
                    var locationUpdate = false
                    let lastDistance = newLocation.distance(from: currentLocation)
                    let speed = lastDistance / newLocation.timestamp.timeIntervalSinceReferenceDate - currentLocation.timestamp.timeIntervalSinceReferenceDate
                    
                    if lastDistance > currentLocation.horizontalAccuracy && lastDistance > newLocation.horizontalAccuracy && speed < 70 {
                        self.dbManager.update {
                            manager.track?.distance += CGFloat(lastDistance)
                        }
                        self.dbManager.add(manager.track)
                        locationUpdate = true
                    }
                    
                    if locationUpdate == true {
                        let pit = PitModel()
                        pit.latitude = newLocation.coordinate.latitude
                        pit.longitude = newLocation.coordinate.longitude
                        pit.time = "\(Date().timeIntervalSince1970 * 1000)"
                        pit.tag = "origin"
                        pit.value = 0.0
                        
                        self.dbManager.update {
                            manager.track?.pits.append(pit)
                        }
                        self.dbManager.add(manager.track)
                        
                        manager.delegate?.locationUpdated(location: currentLocation, trackDist: Double(manager.track!.distance))
                    }
                    
                    // Calculate maximum speed for last 5 minutes
                    if newLocation.horizontalAccuracy <= 10 {
                        if manager.maxSpeed < newLocation.speed {
                            manager.maxSpeed = newLocation.speed
                        }
                    }
                }
                
                manager.currentLocation = newLocation
            }
        }
        
        onSend = { points, track in
            //prepare params for sending
            let data64 = UARoadsSDK.sharedInstance.encodePoints(points)
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
            
            //try to send data
            NetworkManager.sharedInstance.sendPits(params: params, handler: { success in
                if success {
                    print("SUCCESS")
                } else {
                    print("NOT SUCCESS")
                }
            })
        }
        
        motionCallback = { [unowned self] in
            let pred = NSPredicate(format: "status == 0")
            let result = self.dbManager.objects(type: TrackModel.self)?.filter(pred)
            if let result = result, result.count > 0 {
                self.dbManager.update {
                    for item in result {
                        if Date().timeIntervalSince(item.date) > 10 {
                            item.status = TrackStatus.waitingForUpload.rawValue
                            
                            //send data ERROR!!!!!!!!!!!!!!!!
//                            self.onSend?(Array(item.pits), item)
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
    
    var onPit: ((_ currentPit: Double) -> ())?
    var onMotionStart: ((_ point: Double, _ filtered: Bool) -> ())?
    var onMotionStop: (() -> ())?
    var onLocation: ((_ locations: [CLLocation]) -> ())?
    var motionCallback: (() -> ())?
    var onSend: ((_ points: [PitModel], _ track: TrackModel) -> ())?
    
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









