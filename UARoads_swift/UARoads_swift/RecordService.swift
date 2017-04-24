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
//            if manager.skipLocationPoints > 0 {
//                manager.skipLocationPoints -= 1
//                return
//            }
            
            if let newLocation = locations.first {
                var locationUpdate = false
                if manager.currentLocation != nil {
                    let lastDistance = newLocation.distance(from: manager.currentLocation!)
                    let speed = lastDistance / newLocation.timestamp.timeIntervalSinceReferenceDate - manager.currentLocation!.timestamp.timeIntervalSinceReferenceDate
                    
                    if lastDistance > manager.currentLocation!.horizontalAccuracy && lastDistance > newLocation.horizontalAccuracy && speed < 70 {
                        self.dbManager.update {
                            manager.track?.distance += CGFloat(lastDistance)
                        }
                        self.dbManager.add(manager.track)
                        locationUpdate = true
                    }
                } else {
                    locationUpdate = false
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
                    
                    manager.currentLocation = newLocation
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
        
        motionCallback = { points in
            return (points as NSArray).componentsJoined(by: "+")
        }
    }
    static let sharedInstance = RecordService()
 
    //================
    
    public let dbManager: RealmManager
    public let motionManager: MotionManager
    public let locationManager: LocationManager
    
    var onPit: ((_ currentPit: Double) -> ())?
    var onMotionStart: ((_ point: Double, _ filtered: Bool) -> ())?
    var onMotionStop: (() -> ())?
    var onLocation: ((_ locations: [CLLocation]) -> ())?
    var motionCallback: ((_ points: [PitModel]) -> String)?
    
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









