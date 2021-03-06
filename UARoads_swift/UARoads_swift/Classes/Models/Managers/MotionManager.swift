//
//  MotionManager.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/11/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import CoreLocation
import AudioToolbox
import CallKit
import CoreMotion


protocol MotionManagerDelegate {
    func statusChanged(newStatus: RecordStatus, oldStatus: RecordStatus)
}


final class MotionManager: NSObject, CXCallObserverDelegate {
    // MARK: Properties
    var delegate: MotionManagerDelegate?
    var status: RecordStatus = .notActive {
        didSet {
            print(status)
            self.delegate?.statusChanged(newStatus: status, oldStatus: oldValue)
        }
    }
    var track: TrackModel?
   
    private let callObserver = CXCallObserver()
    private let motionManager = CMMotionManager()
    private var pointCount: Int = 0
    private var timerPit: Timer?
    private var timerMotion: Timer?
    private var lastSentPitTimeInterval = 0.0
    
    // MARK: Init funcs
    override init() {
        super.init()
        
        self.motionManager.deviceMotionUpdateInterval = 0.02777
        
        let customQueue = DispatchQueue(label: "uaroads_queue",
                                        qos: DispatchQoS.background,
                                        attributes: DispatchQueue.Attributes.concurrent,
                                        autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem,
                                        target: nil)
        self.callObserver.setDelegate(self, queue: customQueue)
    }
    
    // MARK: Overriden funcs
    override func copy() -> Any {
        fatalError("don`t use copy!")
    }
    override func mutableCopy() -> Any {
        fatalError("don`t use copy!")
    }
    //=======================
    
    
    // MARK: Public funcs
    func startRecording() {
        let autostart = SettingsManager.sharedInstance.routeRecordingAutostart
        DateManager.sharedInstance.setFormat("dd MMMM yyyy HH:mm")
        let initialTitle = DateManager.sharedInstance.getDateFormatted(Date())
        
        startRecording(title: initialTitle, autostart: autostart)
    }
    
    func stopRecording() {
        let autostart = SettingsManager.sharedInstance.routeRecordingAutostart
        let actionName = autostart ? "stopAutoRecord" : "stopManualRecord"
        AnalyticManager.sharedInstance.reportEvent(category: "Record", action: actionName, label: nil, value: nil)
        
        UIApplication.shared.isIdleTimerDisabled = false
        status = .notActive
        motionManager.stopDeviceMotionUpdates()
        stopTimers()
        
        completeActiveTracks()
    }

    func pauseRecording() {
        AnalyticManager.sharedInstance.reportEvent(category: "Record", action: "pauseManualRecord", label: nil, value: nil)
        UIApplication.shared.isIdleTimerDisabled = false
        status = .paused
        motionManager.stopDeviceMotionUpdates()
        stopTimers()
    }
    
    func resumeRecording() {
        status = .active
        motionManager.startDeviceMotionUpdates()
        restartTimers()
    }
    
    func completeActiveTracks() {
        RecordService.shared.onMotionCompleted?()
        RecordService.shared.onSend?()
    }
    
    func playSound(_ soundName: String) {
        var sound: SystemSoundID = 0
        if let soundURL = Bundle.main.url(forResource: soundName, withExtension: "aiff") {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &sound)
            AudioServicesPlaySystemSound(sound)
        }
    }
    
    private func startRecording(title: String, autostart: Bool = false) {
        let actionName = autostart ? "startAutoRecord" : "startManualRecord"
        AnalyticManager.sharedInstance.reportEvent(category: "Record", action: actionName, label: nil, value: nil)
        if status == .notActive {
            track = TrackModel()
            track?.autoRecord = autostart
            track?.title = title
            track?.date = Date()
            track?.status = TrackStatus.active.rawValue
            DateManager.sharedInstance.setFormat("yyyyMMddhhmmss")
            let id = "\(title)-\(DateManager.sharedInstance.getDateFormatted(track!.date))"
            track?.trackID = id.md5()
            RecordService.shared.dbManager.add(track)
            
            status = .active
            motionManager.startDeviceMotionUpdates()
            motionManager.startAccelerometerUpdates()
            
            restartTimers()
        }
    }
    
    private func stopTimers() {
        if let timer = timerPit {
            timer.invalidate()
        }
        if let timer = timerMotion {
            timer.invalidate()
        }
    }
    
    private func restartTimers() {
        stopTimers()
        timerPit = Timer.scheduledTimer(timeInterval: motionManager.deviceMotionUpdateInterval,
                                        target: self,
                                        selector: #selector(timerPitAction),
                                        userInfo: nil,
                                        repeats: true)
        timerMotion = Timer.scheduledTimer(timeInterval: updateLocationIntervalDefault,
                                           target: self,
                                           selector: #selector(timerMotionAction),
                                           userInfo: nil,
                                           repeats: true)
    }
    
    private func pauseRecordingForCall() {
        UIApplication.shared.isIdleTimerDisabled = false
        status = .pausedForCall
        motionManager.stopDeviceMotionUpdates()
        stopTimers()
    }
    
    
    // MARK: Action funcs
    @objc private func timerMotionAction() {
        RecordService.shared.onLocation!()
    }
    
    @objc private func timerPitAction() {
        let currTime = Date().timeIntervalSince1970
        let currentPit = getAccelerometerData()
        if currTime - lastSentPitTimeInterval > PitInterval {
            RecordService.shared.onPit?(currentPit)
            lastSentPitTimeInterval = currTime
        }
        
        if let block = RecordService.shared.onMotionStart {
            let filtred = currentPit > 0
            block(currentPit, filtred)
        }
        
    }
    
    
    // MARK: Delegate funcs:
    //MARK: —CXCallObserverDelegate
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasConnected {
            DispatchQueue.main.async { [unowned self] in
                if self.status == .active {
                    AnalyticManager.sharedInstance.reportEvent(category: "Record",
                                                               action: "pauseForCall",
                                                               label: nil,
                                                               value: nil)
                    self.pauseRecordingForCall()
                }
            }
        } else {
            DispatchQueue.main.async { [unowned self] in
                if self.status == .pausedForCall {
                    AnalyticManager.sharedInstance.reportEvent(category: "Record",
                                                               action: "resumeAfterCall",
                                                               label: nil,
                                                               value: nil)
                    addNotification(text: "Track recording resumed.", time: 2.0)
                    self.resumeRecording()
                }
            }
        }
    }
    
    func getAccelerometerData() -> Double {
        var accelData: Double = 0
        if let accelerometerData = motionManager.accelerometerData {
            let accX = accelerometerData.acceleration.x
            let accY = accelerometerData.acceleration.y
            let accZ = accelerometerData.acceleration.z
            
            accelData = fabs(sqrt(accX * accX + accY * accY + accZ * accZ) - 1)
        } else {
            // TODO: delete accelerometerData simulator
            let randDigit: Double = Double(arc4random() % 1000 + 1)
            accelData = randDigit / 1000
        }
        
        if let mp = track?.maxPit, mp > accelData {
            track?.maxPit = mp
        }
        
        return accelData
    }
    
    
    
}










