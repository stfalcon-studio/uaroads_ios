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
        //init events
        self.onMotion = { point, filtered in
            let manager = RecordService.sharedInstance.motionManager
            if (manager.graphView != nil) && !(manager.graphView?.isHidden)! {
                manager.graphView?.addValue(CGFloat(point), isFiltered: filtered)
            }
        }
        
        self.onLocation = { newLocation in
            let manager = RecordService.sharedInstance.motionManager
            var locationUpdate = false
            if manager.currentLocation != nil {
                let lastDistance = newLocation.distance(from: manager.currentLocation!)
                let speed = lastDistance / newLocation.timestamp.timeIntervalSinceReferenceDate - manager.currentLocation!.timestamp.timeIntervalSinceReferenceDate
                
                if lastDistance > manager.currentLocation!.horizontalAccuracy && lastDistance > newLocation.horizontalAccuracy && speed < 70 {
                    RecordService.sharedInstance.dbManager.update {
                        manager.track?.distance += CGFloat(lastDistance)
                    }
                    RecordService.sharedInstance.dbManager.add(manager.track)
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
                
                RecordService.sharedInstance.dbManager.update {
                    manager.track?.pits.append(pit)
                }
                RecordService.sharedInstance.dbManager.add(manager.track)
                
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
    static let sharedInstance = RecordService()
 
    //================
    
    public let dbManager = RealmManager()
    public let motionManager = MotionManager()
    
    let onLocation: ((_ newLocation: CLLocation) -> ())
    let onMotion: ((_ point: Double, _ filtered: Bool) -> ())
    
    func start() {
        motionManager.startRecording()
    }
    
    func stop() {
        motionManager.stopRecording()
    }
    
    func pauseRecording() {
        motionManager.pauseRecording()
    }
    
    func stopRecording() {
        motionManager.stopRecording()
    }
}
