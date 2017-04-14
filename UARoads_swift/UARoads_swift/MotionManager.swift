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
import StfalconSwiftExtensions
import UHBConnectivityManager
import RealmSwift

enum MotionStatus {
    case notActive
    case active
    case paused
    case pausedForCall
}

protocol MotionManagerDelegate {
    func locationUpdated(location: CLLocation, trackDist: Double)
    func maxPitUpdated(maxPit: Double)
    func statusChanged(newStatus: MotionStatus)
}

final class MotionManager: NSObject, CXCallObserverDelegate {
    fileprivate let realm = try? Realm()
    
    private override init() {
        super.init()
        
        LocationManager.sharedInstance.manager.pausesLocationUpdatesAutomatically = true
        LocationManager.sharedInstance.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        LocationManager.sharedInstance.manager.allowsBackgroundLocationUpdates = true
        LocationManager.sharedInstance.manager.requestAlwaysAuthorization()
        
        self.motionManager.deviceMotionUpdateInterval = 0.02777
        self.reloadSettings()
        
        self.callObserver.setDelegate(self, queue: DispatchQueue(label: "uaroads_queue", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: nil))
    }
    static let sharedInstance = MotionManager()
    override func copy() -> Any {
        fatalError("don`t use copy!")
    }
    override func mutableCopy() -> Any {
        fatalError("don`t use copy!")
    }
    
    //=======================
    
    var delegate: MotionManagerDelegate?
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
    fileprivate var currentPit: Double = 0.0
    fileprivate var maxPit: Double = 0.0
    fileprivate var currentPitTime: Date?
    fileprivate var maxSpeed: CGFloat?
    fileprivate var dataToSave: Date?
    fileprivate var currentLocation: CLLocation?
    fileprivate var lastAccX: CGFloat?
    fileprivate var lastAccY: CGFloat?
    fileprivate var lastAccZ: CGFloat?
    
    func startRecording(autostart: Bool = false) {
        DateManager.sharedInstance.setFormat("dd MMMM yyyy HH:mm")
        let initialTitle = DateManager.sharedInstance.getDateFormatted(Date())
        
        startRecording(title: initialTitle, autostart: autostart)
    }
    
    func stopRecording(autostart: Bool = false) {
        UIApplication.shared.isIdleTimerDisabled = false
        status = .notActive
        motionManager.stopDeviceMotionUpdates()
        LocationManager.sharedInstance.manager.stopUpdatingLocation()
        stopTimers()
        
        completeActiveTracks()
        
        graphView?.clear()
        currentLocation = nil
        pitBuffer.removeAll()
    }

    func pauseRecording() {
        UIApplication.shared.isIdleTimerDisabled = false
        status = .paused
        motionManager.stopDeviceMotionUpdates()
        stopTimers()
    }
    
    func resumeRecording() {
        currentLocation = nil
        status = .active
        motionManager.startDeviceMotionUpdates()
        LocationManager.sharedInstance.manager.startUpdatingLocation()
        restartTimers()
        reloadSettings()
    }
    
    func reloadSettings() {
        //TODO:
//        if ([Uaroads session].settingsPreventLock)
//        [UIApplication sharedApplication].idleTimerDisabled = YES;
//        else
//        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
    
    fileprivate func completeActiveTracks() {
        let pred = NSPredicate(format: "status == 0")
        let result = RealmHelper.objects(type: TrackModel.self)?.filter(pred)
        if let result = result, result.count > 0 {
            try? realm?.write{
                for item in result {
                    if Date().timeIntervalSince(item.date) > 10 {
                        item.status = TrackStatus.waitingForUpload.rawValue
//                        [UaroadsSession sharedSession].totalDistance += track.distance;
                    }
                }
            }
        }
        sendDataActivity()
    }
    
    fileprivate func sendDataActivity() {
        let pred = NSPredicate(format: "(status == 2) OR (status == 3)")
        let result = RealmHelper.objects(type: TrackModel.self)?.filter(pred)
        if let result = result, result.count > 0 {
            if UHBConnectivityManager.shared().isConnected() == true {
                let track = result.first
                try? realm?.write {
                    track?.status = TrackStatus.uploading.rawValue
                }
                UARoadsSDK.sharedInstance.send(track: track!, handler: { val in
                    print(val)
                })
            }
        }
    }
    
    fileprivate func startRecording(title: String, autostart: Bool = false) {
        track = TrackModel()
        track?.autoRecord = autostart
        track?.title = title
        track?.date = Date()
        track?.status = TrackStatus.active.rawValue
        track?.distance = 0.0
        DateManager.sharedInstance.setFormat("yyyyMMddhhmmss")
        let id = "\(title)-\(DateManager.sharedInstance.getDateFormatted(track!.date))"
        track?.trackID = id.md5()
        try? realm?.write {
            realm?.add(track!, update: true)
        }

        currentLocation = nil
        skipLocationPoints = 3
        status = .active
        motionManager.startDeviceMotionUpdates()
        motionManager.startAccelerometerUpdates()
        LocationManager.sharedInstance.manager.startUpdatingLocation()
        
        restartTimers()
        reloadSettings()
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
        if let accelerometerData = motionManager.accelerometerData {
            let accX = accelerometerData.acceleration.x
            let accY = accelerometerData.acceleration.y
            let accZ = accelerometerData.acceleration.z
            
            var f: Double = fabs(sqrt(accX * accX + accY * accY + accZ * accZ) - 1)
            
            //Pit simulator
            if f == 1.0 {
                if arc4random() % 20 == 0 {
                    f = pow(Double((arc4random() % 800) / 1000), 2.0)
                } else {
                    f = pow(Double((arc4random() % 100) / 1000), 2.0)
                }
            }
            
            var filtered = true
            
            let minRecValue: Double = 0.0
            if f > minRecValue {
                if f > currentPit {
                    currentPit = f
                    currentPitTime = Date()
                }
                
                filtered = false
            }
            
            if (graphView != nil) && !(graphView?.isHidden)! {
                graphView?.addValue(CGFloat(f), isFiltered: filtered)
            }
        }
    }
    
    @objc fileprivate func timerMaxPitAction() {
        delegate?.maxPitUpdated(maxPit: maxPit)
        maxPit = 0.0
    }
    
    @objc fileprivate func timerPitAction() {
        if currentPit > maxPit {
            maxPit = currentPit
        }
        if currentPit > 0.0 {
            //
        
//            if (currentPit > 0) {
//                if ([Uaroads session].settingsAllowSound) {
//                    int pitN = (int)(currentPit / 0.3);
//                    if (pitN > 0) {
//                        if (pitN>5) pitN = 5;
//                        NSString * pitSound = [NSString stringWithFormat:@"pit-%d", pitN];
//                        [self playSound:pitSound type:@"aiff"];
//                    }
//                }

            let pit = PitModel()
            pit.latitude = LocationManager.sharedInstance.manager.location?.coordinate.latitude ?? 0.0
            pit.longitude = LocationManager.sharedInstance.manager.location?.coordinate.longitude ?? 0.0
            pit.track = track
            pit.value = currentPit
            pit.time = "\(Date().timeIntervalSince1970 * 1000)"
            pit.tag = "origin"
            pit.add()
            
            track?.pits.append(pit)
        }

        currentPit = 0.0
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










