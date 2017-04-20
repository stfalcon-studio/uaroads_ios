//
//  AutostartManager.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/18/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import CoreLocation

final class AutostartManager: NSObject {
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdate(note:)), name: NSNotification.Name.init(rawValue: Note.locationUpdate.rawValue), object: nil)
    }
    override func copy() -> Any {
        fatalError("don`t use copy!")
    }
    override func mutableCopy() -> Any {
        fatalError("don`t use copy!")
    }
    static let sharedInstance = AutostartManager()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //=================
    let Min_speed_to_start_recording: Double = 5.56 /// m/s ( 20 km/h) //TODO: change it back!!!
    let Max_speed_to_stop_recording: Double = 4.67 /// m/s (15 km/h)
    var status: Int = 2 {
        willSet {
            AnalyticManager.sharedInstance.reportHEAPEvent(category: "Autostart",
                                                           action: "UpdateAutostartStatus",
                                                           properties: ["OldStatus":self.status, "NewStatus":newValue])
        }
    }//TODO: give some understandable name!
    var lastMaxSpeed: Double = 0.0
    
    private var startNotified: Bool = false
    
    private var autostartTimer: Timer?
    private var autostopTimer: Timer?
    
    @objc private func autostartTimeoutTimerCheck() {
        AnalyticManager.sharedInstance.reportHEAPEvent(category: "Autostart",
                                                       action: "Timeout",
                                                       properties: ["Status":status,"LastMaxSpeed":lastMaxSpeed])
        if status == 1 {
            status = 0
            LocationManager.sharedInstance.manager.stopUpdatingLocation()
            addNotification(text: "Track recording automaticaly stoped.", time: 1.0, sound: "stop-rec-uk.m4a")
            startNotified = false
        } else {
            autostartTimer?.invalidate()
        }
        lastMaxSpeed = 0.0
    }
    
    @objc private func autostopTimerCheck() {
        AnalyticManager.sharedInstance.reportHEAPEvent(category: "Autostart",
                                                       action: "Autostop Timeout",
                                                       properties: ["Status":status,"LastMaxSpeed":lastMaxSpeed])
        if status == 2 {
            if lastMaxSpeed < Max_speed_to_stop_recording {
                stopRecording()
            }
        }
        autostopTimer?.invalidate()
        lastMaxSpeed = 0.0
    }
    
    func startRecording() {
        let autostopCheckInterval: TimeInterval = 120
        
        if autostartTimer != nil {
            autostartTimer?.invalidate()
            autostartTimer = nil
        }
        
        if MotionManager.sharedInstance.status == .notActive {
            AnalyticManager.sharedInstance.reportHEAPEvent(category: "Autostart", action: "Start recording", properties: nil)
            status = 2
            if autostartTimer != nil {
                autostartTimer?.invalidate()
                autostartTimer = nil
            }
            
            autostopTimer = Timer.scheduledTimer(timeInterval: autostopCheckInterval, target: AutostartManager.sharedInstance, selector: #selector(autostopTimerCheck), userInfo: nil, repeats: true)
            
            MotionManager.sharedInstance.startRecording(autostart: true)
            
            if !startNotified {
                startNotified = true
                addNotification(text: "Track recording automaticaly started.", time: 1.0, sound: "start-rec-uk.m4a")
            }
        }
    }
    
    func stopRecording() {
        if status == 2 {
            AnalyticManager.sharedInstance.reportHEAPEvent(category: "Autostart", action: "Stop recording", properties: nil)
            if MotionManager.sharedInstance.status != .notActive {
                MotionManager.sharedInstance.stopRecording(autostart: true)
            }
            status = 0
            beginCheckForAutostart()
        }
    }
    
    func setAutostartActive(_ val: Bool) {
        if val {
            LocationManager.sharedInstance.manager.startMonitoringSignificantLocationChanges()
        } else {
            status = 0
            LocationManager.sharedInstance.manager.stopUpdatingLocation()
            LocationManager.sharedInstance.manager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    func beginCheckForAutostart() {
        let autostartTimeoutInterval: TimeInterval = 240
        
        status = 1
        
        if autostartTimer != nil {
            autostartTimer?.invalidate()
            autostartTimer = nil
        }
        
        autostartTimer = Timer.scheduledTimer(timeInterval: autostartTimeoutInterval, target: AutostartManager.sharedInstance, selector: #selector(autostartTimeoutTimerCheck), userInfo: nil, repeats: false)
        
        LocationManager.sharedInstance.manager.startUpdatingLocation()
    }
    
    @objc fileprivate func locationUpdate(note: NSNotification) {
        if let lastLocation = (note.object as? [CLLocation])?.last {
            let speed = lastLocation.speed
            let hAccuracy = lastLocation.horizontalAccuracy
            
            if MotionManager.sharedInstance.status == .notActive || status == 2 {
                switch status {
                case 0:
                    beginCheckForAutostart()
                    
                case 1:
                    if speed > Min_speed_to_start_recording && hAccuracy < 20 {
                        lastMaxSpeed = lastLocation.speed
                        startRecording()
                    }
                    
                case 2:
                    if speed > lastMaxSpeed && hAccuracy < 20 {
                        lastMaxSpeed = lastLocation.speed
                    }
                    
                default: break
                }
            }
        }
    }
}














