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
import StfalconSwiftExtensions
import UHBConnectivityManager

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
    private override init() {
        super.init()
        
        LocationManager.sharedInstance.manager.pausesLocationUpdatesAutomatically = true
        LocationManager.sharedInstance.manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        LocationManager.sharedInstance.manager.allowsBackgroundLocationUpdates = true
        LocationManager.sharedInstance.manager.requestAlwaysAuthorization()
        
        self.motionManager.deviceMotionUpdateInterval = 0.02777
        self.reloadSettings()
        
        self.callObserver.setDelegate(self, queue: DispatchQueue(label: "uaroads_queue", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.workItem, target: nil))
        
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdate(note:)), name: NSNotification.Name.init(rawValue: Note.locationUpdate.rawValue), object: nil)
    }
    static let sharedInstance = MotionManager()
    override func copy() -> Any {
        fatalError("don`t use copy!")
    }
    override func mutableCopy() -> Any {
        fatalError("don`t use copy!")
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //=======================
    
    var delegate: MotionManagerDelegate?
    var status: MotionStatus = .notActive
    var track: TrackModel?
    weak var graphView: GraphView?
    var pitBuffer = [Any]()
    
    fileprivate let MaxPitValue = 5.4
    fileprivate let PitInterval = 0.5
    fileprivate let queue = OperationQueue()
    fileprivate let callObserver = CXCallObserver()
    fileprivate let motionManager = CMMotionManager()
    
    fileprivate var pointCount: Int = 0
    fileprivate var skipLocationPoints: Int = 0
    fileprivate var timerPit: Timer?
    fileprivate var timerMaxPit: Timer?
    fileprivate var timerMotion: Timer?
    fileprivate var currentPit: Double = 0.0
    fileprivate var maxPit: Double = 0.0
    fileprivate var currentPitTime: Date?
    fileprivate var maxSpeed: Double = 0.0
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
            RealmManager.sharedInstance.update {
                for item in result {
                    if Date().timeIntervalSince(item.date) > 10 {
                        item.status = TrackStatus.waitingForUpload.rawValue
                        //                        [UaroadsSession sharedSession].totalDistance += track.distance;
                    }
                }
            }
        }
        UARoadsSDK.sharedInstance.sendDataActivity()
    }
    
    fileprivate func startRecording(title: String, autostart: Bool = false) {
        if status == .notActive {
            track = TrackModel()
            track?.autoRecord = autostart
            track?.title = title
            track?.date = Date()
            track?.status = TrackStatus.active.rawValue
            track?.distance = 0.0
            DateManager.sharedInstance.setFormat("yyyyMMddhhmmss")
            let id = "\(title)-\(DateManager.sharedInstance.getDateFormatted(track!.date))"
            track?.trackID = id.md5()
            RealmManager.sharedInstance.add(track)
            
            currentLocation = nil
            skipLocationPoints = 3
            status = .active
            motionManager.startDeviceMotionUpdates()
            motionManager.startAccelerometerUpdates()
            LocationManager.sharedInstance.manager.startUpdatingLocation()
            
            restartTimers()
            reloadSettings()
        }
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
            var pitN = Int(currentPit/0.3)
            if pitN > 5 {
                pitN = 5
            }
            let pitSound = "pit-\(pitN)"
            print(pitSound)
            print(currentPit)
            print(maxPit)
            
            playSound(pitSound)

            let pit = PitModel()
            pit.latitude = LocationManager.sharedInstance.manager.location?.coordinate.latitude ?? 0.0
            pit.longitude = LocationManager.sharedInstance.manager.location?.coordinate.longitude ?? 0.0
            pit.value = currentPit
            pit.time = "\(Date().timeIntervalSince1970 * 1000)"
            pit.tag = "origin"
            
            RealmManager.sharedInstance.update {
                track?.pits.append(pit)
            }
            RealmManager.sharedInstance.add(track)
        }
        currentPit = 0.0
    }
    
    fileprivate func pauseRecordingForCall() {
        UIApplication.shared.isIdleTimerDisabled = false
        status = .pausedForCall
        motionManager.stopDeviceMotionUpdates()
        stopTimers()
    }
    
    fileprivate func playSound(_ soundName: String) {
        var sound: SystemSoundID = 0
        if let soundURL = Bundle.main.url(forResource: soundName, withExtension: "aiff") {
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &sound)
            AudioServicesPlaySystemSound(sound)
        }
    }
    
    @objc fileprivate func locationUpdate(note: NSNotification) {
        if skipLocationPoints > 0 {
            skipLocationPoints -= 1
            return
        }
        
        if let newLocation = (note.object as? [CLLocation])?.first {
            var locationUpdate = false
            if currentLocation != nil {
                let lastDistance = newLocation.distance(from: currentLocation!)
                let speed = lastDistance / newLocation.timestamp.timeIntervalSinceReferenceDate - currentLocation!.timestamp.timeIntervalSinceReferenceDate
                
                if lastDistance > currentLocation!.horizontalAccuracy && lastDistance > newLocation.horizontalAccuracy && speed < 70 {
                    RealmManager.sharedInstance.update {
                        self.track?.distance += CGFloat(lastDistance)
                    }
                    RealmManager.sharedInstance.add(track)
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
                
                RealmManager.sharedInstance.update {
                    track?.pits.append(pit)
                }
                RealmManager.sharedInstance.add(track)
                
                currentLocation = newLocation
                delegate?.locationUpdated(location: currentLocation!, trackDist: Double(track!.distance))
            }
            
            // Calculate maximum speed for last 5 minutes
            if newLocation.horizontalAccuracy <= 10 {
                if maxSpeed < newLocation.speed {
                    maxSpeed = newLocation.speed
                }
            }
        }
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
                    addNotification(text: "Track recording resumed.", time: 2.0)
                    self.resumeRecording()
                }
            }
        }
    }
}










