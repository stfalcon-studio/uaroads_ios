//
//  MotionManager.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/11/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import CoreLocation
import CallKit
import CoreMotion
import UserNotifications

enum MotionStatus {
    case notActive
    case active
    case paused
    case pausedForCall
}

protocol MotionDelegate {
    func locationUpdated(location: CLLocation, trackDist: CGFloat)
    func maxPitUpdated(maxPit: CGFloat)
    func statusChanged(newStatus: MotionStatus)
}

final class MotionManager: NSObject, CXCallObserverDelegate {
    private override init() {
        super.init()
        
        LocationManager.sharedInstance.manager.pausesLocationUpdatesAutomatically = true
        LocationManager.sharedInstance.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        LocationManager.sharedInstance.manager.allowsBackgroundLocationUpdates = true
        LocationManager.sharedInstance.manager.requestAlwaysAuthorization()
        
        self.motionManager.deviceMotionUpdateInterval = 0.02777
        self.reloadSettings()
        
        self.callObserver.setDelegate(self, queue: nil)
    }
    static let sharedInstance = MotionManager()
    override func copy() -> Any {
        fatalError("don`t use copy!")
    }
    override func mutableCopy() -> Any {
        fatalError("don`t use copy!")
    }
    
    var delegate: MotionDelegate?
    var status: MotionStatus?
    var track: TrackModel?
    weak var graphView: GraphView?
    var pitBuffer = [Any]()
    
    fileprivate let MaxPitValue = 5.4
    fileprivate let PitInterval = 0.5
    fileprivate let queue = OperationQueue()
    fileprivate let callObserver = CXCallObserver()
    fileprivate let motionManager = CMMotionManager()
    
    fileprivate var pointCount: Int = 0
    fileprivate var skipLocationPoints: Int?
    fileprivate var timerPit: Timer?
    fileprivate var timerMaxPit: Timer?
    fileprivate var timerMotion: Timer?
    fileprivate var currentPit: CGFloat = 0.0
    fileprivate var maxPit: CGFloat = 0.0
    fileprivate var currentPitTime: Date?
    fileprivate var maxSpeed: CGFloat?
    fileprivate var dataToSave: Date?
    fileprivate var lastAccX: CGFloat?
    fileprivate var lastAccY: CGFloat?
    fileprivate var lastAccZ: CGFloat?
    
    func startRecording(autostart: Bool = false) {
        DateManager.sharedInstance.setFormat("dd MMMM yyyy HH:mm")
        let initialTitle = DateManager.sharedInstance.getDateFormatted(Date())
        
        startRecording(title: initialTitle, autostart: autostart)
    }
    
    func stopRecording(autostart: Bool = false) {
        //
    }

    func pauseRecording() {
        //
    }
    
    func resumeRecording() {
        //
    }
    
    func reloadSettings() {
        //TODO:
//        if ([Uaroads session].settingsPreventLock)
//        [UIApplication sharedApplication].idleTimerDisabled = YES;
//        else
//        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
    
    fileprivate func startRecording(title: String, autostart: Bool = false) {
        if self.status == .notActive {
            //if (autostart) {
            //  [[UaroadsAnalyticManager sharedManager] reportEventWithCategory:@"Record" action:@"startAutoRecord" label:nil value:nil];
            //} else {
            //  [[UaroadsAnalyticManager sharedManager] reportEventWithCategory:@"Record" action:@"startManualRecord" label:nil value:nil];
            //            }
            self.track = TrackModel(trackID: nil, title: title, date: nil, status: nil, distance: nil, maxPit: nil, pits: nil, autoRecord: autostart, debug: nil, trackFileName: nil)
        }

//            if ([Uaroads session].settingsPreventLock)
//            [UIApplication sharedApplication].idleTimerDisabled = YES;
//            self.track = [UaroadsTrack trackWithTitle:title autoRecord:autostart];
//            currentLocation = nil;
//            skipLocationPoints = 3;
//            self.status = MotionListenerStatusActive;
//            [self.motionManager startDeviceMotionUpdates];
//            [self.motionManager startAccelerometerUpdates];
//            
//            [self.locationManager startUpdatingLocation];
//            
//            [self restartTimers];
//            [self reloadSettings];
//        }
    }
    
    fileprivate func stopTimers() {
        if let timer = timerMaxPit {
            timer.invalidate()
        }
        if let timer = timerPit {
            timer.invalidate()
        }
        if let timer = timerMotion {
            timer.invalidate()
        }
    }
    
    fileprivate func restartTimers() {
        stopTimers()
        timerPit = Timer.scheduledTimer(timeInterval: PitInterval,
                                        target: self,
                                        selector: #selector(timerPitAction),
                                        userInfo: nil,
                                        repeats: true)
        
        timerMaxPit = Timer.scheduledTimer(timeInterval: 1.0,
                                           target: self,
                                           selector: #selector(timerMaxPitAction),
                                           userInfo: nil,
                                           repeats: true)
        
        timerMotion = Timer.scheduledTimer(timeInterval: self.motionManager.deviceMotionUpdateInterval,
                                           target: self,
                                           selector: #selector(timerMotionAction),
                                           userInfo: nil,
                                           repeats: true)
    }
    
    @objc fileprivate func timerMotionAction() {
        //
    }
    
    @objc fileprivate func timerMaxPitAction() {
//        [self.delegate motionListenerController:self maxPitUpdated:maxPit];
//        maxPit = 0;
    }
    
    @objc fileprivate func timerPitAction() {
        if currentPit > maxPit {
            maxPit = currentPit
        }
        if currentPit > 0.0 {
            //
        }
//            if (currentPit > 0) {
//                if ([Uaroads session].settingsAllowSound) {
//                    int pitN = (int)(currentPit / 0.3);
//                    if (pitN > 0) {
//                        if (pitN>5) pitN = 5;
//                        NSString * pitSound = [NSString stringWithFormat:@"pit-%d", pitN];
//                        [self playSound:pitSound type:@"aiff"];
//                    }
//                }
//                [UaroadsSimplePit addPitToTrack:self.track location:nil acceleration:nil value:currentPit time:currentPitTime];
//                
//                
//            }
//            currentPit = 0;
    }
    
    fileprivate func pauseRecordingForCall() {
        //
    }
    
    //MARK: CXCallObserverDelegate
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasConnected {
            DispatchQueue.main.async { [unowned self] in
                if self.status == .active {
                    self.pauseRecordingForCall()
                }
            }
        } else {
            DispatchQueue.main.async { [unowned self] in
                if self.status == .pausedForCall {
                    
                    //create and add local user notification
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Date().addingTimeInterval(2.0).timeIntervalSinceNow,
                                                                    repeats: false)
                    
                    let content = UNMutableNotificationContent()
                    content.body = NSLocalizedString("Track recording resumed.", comment: "noteBody")
                    content.title = NSLocalizedString("UARoads", comment: "noteTitle")
                    content.userInfo = ["resume":"action"]
                    
                    let request = UNNotificationRequest(identifier: "uaroads", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                    self.resumeRecording()
                }
            }
        }
    }
}










