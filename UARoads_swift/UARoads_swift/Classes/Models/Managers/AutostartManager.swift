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
    let autorecordPauseDuration: TimeInterval = 20
    
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
    
    private func pauseFinishedTimerAction() {
        
    }
    
//    private override init() {
//        super.init()
//        self.locationManager.delegate = self
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        self.locationManager.distanceFilter = 0
//        self.locationManager.activityType = .automotiveNavigation
//        self.locationManager.allowsBackgroundLocationUpdates = true
//        
//        if SettingsManager.sharedInstance.routeRecordingAutostart == true {
//            self.locationManager.startMonitoringSignificantLocationChanges()
//        } else {
//            self.locationManager.stopUpdatingLocation()
//            self.locationManager.stopMonitoringSignificantLocationChanges()
//        }
//    }
//    override func copy() -> Any {
//        fatalError("don`t use copy!")
//    }
//    override func mutableCopy() -> Any {
//        fatalError("don`t use copy!")
//    }
//    static let shared = AutostartManager()
//    
//    //=================
////    private let locationManager = CLLocationManager()
//    
//    let Min_speed_to_start_recording: Double = 5.56 /// m/s ( 20 km/h )
//    let Max_speed_to_stop_recording: Double = 4.67  /// m/s ( 15 km/h )
//    var status: Int = 0 {
//        willSet {
//            AnalyticManager.sharedInstance.reportHEAPEvent(category: "Autostart",
//                                                           action: "UpdateAutostartStatus",
//                                                           properties: ["OldStatus":self.status, "NewStatus":newValue])
//        }
//    }//TODO: give some understandable name!
//    var lastMaxSpeed: Double = 0.0
//    
//    private var startNotified: Bool = false
//    
//    private var autostartTimer: Timer?
//    private var autostopTimer: Timer?
//    
//    @objc private func autostartTimeoutTimerCheck() {
//        AnalyticManager.sharedInstance.reportHEAPEvent(category: "Autostart",
//                                                       action: "Timeout",
//                                                       properties: ["Status":status,"LastMaxSpeed":lastMaxSpeed])
//        if status == 1 {
//            status = 0
//            locationManager.stopUpdatingLocation()
//            addNotification(text: "Track recording automaticaly stoped.", time: 1.0, sound: "stop-rec-uk.m4a")
//            startNotified = false
//        } else {
//            autostartTimer?.invalidate()
//        }
//        lastMaxSpeed = 0.0
//    }
//    
//    @objc private func autostopTimerCheck() {
//        AnalyticManager.sharedInstance.reportHEAPEvent(category: "Autostart",
//                                                       action: "Autostop Timeout",
//                                                       properties: ["Status":status,"LastMaxSpeed":lastMaxSpeed])
//        if status == 2 {
//            if lastMaxSpeed < Max_speed_to_stop_recording {
//                stopRecording()
//            }
//        }
//        autostopTimer?.invalidate()
//        lastMaxSpeed = 0.0
//    }
//    
//    func startRecording() {
//        let autostopCheckInterval: TimeInterval = 120
//        
//        if autostartTimer != nil {
//            autostartTimer?.invalidate()
//            autostartTimer = nil
//        }
//        
//        if RecordService.sharedInstance.motionManager.status == .notActive {
//            AnalyticManager.sharedInstance.reportHEAPEvent(category: "Autostart", action: "Start recording", properties: nil)
//            status = 2
//            if autostartTimer != nil {
//                autostartTimer?.invalidate()
//                autostartTimer = nil
//            }
//            
//            autostopTimer = Timer.scheduledTimer(timeInterval: autostopCheckInterval, target: AutostartManager.sharedInstance, selector: #selector(autostopTimerCheck), userInfo: nil, repeats: true)
//            
//            RecordService.sharedInstance.motionManager.startRecording(autostart: true)
//            
//            if !startNotified {
//                startNotified = true
//                addNotification(text: "Track recording automaticaly started.", time: 1.0, sound: "start-rec-uk.m4a")
//            }
//        }
//    }
//    
//    func stopRecording() {
//        if status == 2 {
//            AnalyticManager.sharedInstance.reportHEAPEvent(category: "Autostart", action: "Stop recording", properties: nil)
//            if RecordService.sharedInstance.motionManager.status != .notActive {
//                RecordService.sharedInstance.motionManager.stopRecording(autostart: true)
//            }
//            status = 0
//            beginCheckForAutostart()
//        }
//    }
//    
//    func setAutostartActive(_ val: Bool) {
//        if val {
//            locationManager.startMonitoringSignificantLocationChanges()
//        } else {
//            status = 0
//            locationManager.stopUpdatingLocation()
//            locationManager.stopMonitoringSignificantLocationChanges()
//        }
//    }
//    
//    func beginCheckForAutostart() {
//        let autostartTimeoutInterval: TimeInterval = 240
//        
//        status = 1
//        
//        if autostartTimer != nil {
//            autostartTimer?.invalidate()
//            autostartTimer = nil
//        }
//        
//        autostartTimer = Timer.scheduledTimer(timeInterval: autostartTimeoutInterval,
//                                              target: self,
//                                              selector: #selector(autostartTimeoutTimerCheck),
//                                              userInfo: nil,
//                                              repeats: false)
//        
//        locationManager.startUpdatingLocation()
//    }
//    
//    //MARK: CLLocationManagerDelegate
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        pl(locations as Any)
//        if let lastLocation = locations.last {
//            let speed = lastLocation.speed
//            let hAccuracy = lastLocation.horizontalAccuracy
//            
//            if RecordService.sharedInstance.motionManager.status == .notActive || status == 2 {
//                switch status {
//                case 0:
//                    beginCheckForAutostart()
//                    
//                case 1:
//                    if speed > Min_speed_to_start_recording && hAccuracy < 20 {
//                        lastMaxSpeed = lastLocation.speed
//                        startRecording()
//                    }
//                    
//                case 2:
//                    if speed > lastMaxSpeed && hAccuracy < 20 {
//                        lastMaxSpeed = lastLocation.speed
//                    }
//                    
//                default: break
//                }
//            }
//        }
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        pl("ERROR: \(error.localizedDescription)")
//    }
}


