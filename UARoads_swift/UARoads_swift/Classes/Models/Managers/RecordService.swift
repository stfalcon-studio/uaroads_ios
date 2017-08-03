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
    
    private (set) public var previousLocation: CLLocation?
    
    var onPit: ((_ pitValue: Double) -> ())?
    var onMotionStart: ((_ value: Double, _ filtered: Bool) -> ())?
    var onMotionStop: (() -> ())?
    var onLocation: (() -> ())?
    var onMotionCompleted: (() -> ())?
    var onSend: (() -> ())?
    var trackDistanceUpdated: ((_ newDistance: Double) -> ())?
    var maxPitUpdated: ((_ maxPit: Double) -> ())?
    
    private init() {
        dbManager = RealmManager()
        locationManager = LocationManager()
        motionManager = MotionManager()
        networkManager = NetworkManager.sharedInstance
        
        onPit = { [unowned self] pitValue in
            self.handleOnPitEvent(pitValue: pitValue)
        }
        
        onLocation = { [unowned self] in
            self.handleUpdateLocationEvent()
        }
        
        // TODO: delete onSend block
        onSend = { [unowned self] in
//            self.handleOnSendEvent()
        }
        
        onMotionCompleted = { [unowned self] in
            self.handleMotionCompletedEvent()
        }
    }
    
    
    // MARK: Public funcs
    
    func startRecording() {
        locationManager.requestLocation()
        motionManager.startRecording()
        onLocation?()
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
        pf()
        let manager = self.motionManager

        if let newLocation = locationManager.currentLocation {
            let pit = PitModel()
            pit.latitude = newLocation.coordinate.latitude
            pit.longitude = newLocation.coordinate.longitude
            pit.time = "\(Date().timeIntervalSince1970 * 1000)"
            pit.value = manager.getAccelerometerData()
            pit.horizontalAccuracy = locationManager.currentLocation?.horizontalAccuracy ?? 0.0
            pit.speed = locationManager.currentLocation?.speed ?? 0.0
            
            pit.tag = "cp"
            
            self.dbManager.update {
                manager.track?.pits.append(pit)
            }
            self.dbManager.add(manager.track)
            
            if let previous = self.previousLocation {
                
                let extraDistance = newLocation.distance(from: previous)
                self.dbManager.update {
                    manager.track?.distance += CGFloat(extraDistance)
                }
                self.dbManager.add(manager.track)
                
                let distance = Double(manager.track?.distance ?? 0)
                
                trackDistanceUpdated?(distance)
                maxPitUpdated?(pit.value)
            }
            
            if newLocation.horizontalAccuracy <= 10 {
                if manager.maxSpeed < newLocation.speed {
                    manager.maxSpeed = newLocation.speed
                }
            }
            
            previousLocation = newLocation
        }
    }
    
    private func handleMotionCompletedEvent() {
        //mark the end of the checkpoint
        let coordinate = locationManager.currentLocation?.coordinate
        let pit = PitModel()
        pit.time = "\(Date().timeIntervalSince1970 * 1000)"
        pit.latitude = coordinate?.latitude ?? 0.0
        pit.longitude = coordinate?.longitude ?? 0.0
        pit.tag = "cp"
        pit.value = motionManager.getAccelerometerData()
        pit.horizontalAccuracy = locationManager.currentLocation?.horizontalAccuracy ?? 0.0
        pit.speed = locationManager.currentLocation?.speed ?? 0.0
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
        pf()
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
        pit.horizontalAccuracy = locationManager.currentLocation?.horizontalAccuracy ?? 0.0
        pit.speed = locationManager.currentLocation?.speed ?? 0.0
        
        self.dbManager.update {
            self.motionManager.track?.pits.append(pit)
        }
        self.dbManager.add(self.motionManager.track)
        
        maxPitUpdated?(pitValue)
    }
    
}




