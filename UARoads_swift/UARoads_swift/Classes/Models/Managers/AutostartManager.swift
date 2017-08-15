//
//  AutostartManager.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/18/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import CoreMotion
//import CoreLocation


final class AutostartManager: NSObject/*, CLLocationManagerDelegate*/ {
    
    let Min_speed_to_start_recording: Double = 5.56 /// m/s ( 20 km/h )
    let Max_speed_to_stop_recording: Double = 4.67  /// m/s ( 15 km/h )
    let autorecordPauseDuration: TimeInterval = 150
    
    // MARK: Properies
    static let shared = AutostartManager()
    var motionActivityManager: CMMotionActivityManager?
    var motionPausedTimer: Timer?
    var autostartActive: Bool = false {
        willSet {
            let parameters = ["OldStatus" : self.autostartActive,
                              "NewStatus" : newValue]
            AnalyticManager.sharedInstance.reportHEAPEvent(category: "Autostart",
                                                           action: "UpdateAutostartStatus",
                                                           properties: parameters)
        } didSet {
            if self.autostartActive == true {
                startMonitoringMotion()
            }
        }
    }
    
    // MARK: Init funcs
    
    private override init() {
        super.init()
        
        if AutostartManager.isAutostartAvailable() {
            self.motionActivityManager = CMMotionActivityManager()
        }
    }
    
    
    // MARK: Class funcs
    
    class func isAutostartAvailable() -> Bool {
        let isAvailable = CMMotionActivityManager.isActivityAvailable()
        pl("CMMotionActivityManager.isActivityAvailable() = \(isAvailable)")
        
        return isAvailable
    }
    
    
    // MARK: Public funcs 
    
    func switchAutostart(to active: Bool) {
        if AutostartManager.isAutostartAvailable() {
            autostartActive = active
        }
    }
    
    
    // MARK: Private funcs
    
    func startMonitoringMotion() {
        if !AutostartManager.isAutostartAvailable() {
            return
        }
        
        self.motionActivityManager?.startActivityUpdates(to: OperationQueue.main,
                                                         withHandler: { [weak self] (data: CMMotionActivity!) -> Void in
                                                            self?.handleMotionActivityChanging(data)
        })
    }
    
    private func motionActivity(from data: CMMotionActivity) -> MotionActivity {
        if data.stationary == true {
            return MotionActivity.stationary
        } else if data.walking == true {
            return MotionActivity.walking
        } else if data.running == true {
            return MotionActivity.running
        } else if data.automotive == true {
            return MotionActivity.automotive
        } else if data.cycling == true {
            return MotionActivity.cycling
        }
        
        return MotionActivity.unknown
    }
    
    private func handleMotionActivityChanging(_ motionActivity: CMMotionActivity) {
        let mActivityType = self.motionActivity(from: motionActivity)
        pl("motion activity type ocurred -> \(mActivityType)")
        
        // TODO: delete || mActivityType == .cycling || mActivityType == .walking !!!
        if mActivityType == .automotive || mActivityType == .cycling || mActivityType == .walking {
            startOrResumeRecording()
        } else {
            pauseRecording()
        }
    }
    
    private func startOrResumeRecording() {
        let recordStatus: RecordStatus = RecordService.shared.motionManager.status
        switch recordStatus {
        case .paused:
            RecordService.shared.resumeRecording()
        case .notActive:
            RecordService.shared.startRecording()
            
        default:
            break
        }
    }
    
    private func pauseRecording() {
        if RecordService.shared.motionManager.status == .active {
            RecordService.shared.pauseRecording()
            startMotionPausedTimer()
        }
    }
    
    private func startMotionPausedTimer() {
        if motionPausedTimer == nil {
            motionPausedTimer = Timer.scheduledTimer(withTimeInterval: autorecordPauseDuration,
                                                     repeats: false,
                                                     block: {timer in
                                                        RecordService.shared.stopRecording()
                                                        self.stopTimer()
            })
        }
        
        
    }
    
    private func stopTimer() {
        if motionPausedTimer != nil {
            motionPausedTimer?.invalidate()
            motionPausedTimer = nil
            
        }
    }
    
}


