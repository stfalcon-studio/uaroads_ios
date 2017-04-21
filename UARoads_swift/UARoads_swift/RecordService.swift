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
            pit.latitude = self.motionManager.locationManager.location?.coordinate.latitude ?? 0.0
            pit.longitude = self.motionManager.locationManager.location?.coordinate.longitude ?? 0.0
            pit.value = currentPit
            pit.time = "\(Date().timeIntervalSince1970 * 1000)"
            pit.tag = "origin"
            
            RecordService.sharedInstance.dbManager.update {
                self.motionManager.track?.pits.append(pit)
            }
            RecordService.sharedInstance.dbManager.add(self.motionManager.track)
        }
        
        motionCallback = { points in
            return (points as NSArray).componentsJoined(by: "+")
        }
    }
    static let sharedInstance = RecordService()
 
    //================
    
    public let dbManager = RealmManager()
    public let motionManager = MotionManager()
    
    var onPit: ((_ currentPit: Double) -> ())?
    var onMotionStart: ((_ point: Double, _ filtered: Bool) -> ())?
    var onMotionStop: (() -> ())?
    var motionCallback: ((_ points: [PitModel]) -> String)?
    
    func start() {
        motionManager.startRecording()
    }
    
    func stop() {
        onMotionStop?()
        motionManager.stopRecording()
    }
    
    func pauseRecording() {
        motionManager.pauseRecording()
    }
    
    func stopRecording() {
        motionManager.stopRecording()
    }
}
