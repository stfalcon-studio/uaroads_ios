//
//  RecordService.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/21/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift



final class RecordService {
    
    static let shared = RecordService()
    
    //================
    
    public let dbManager: RealmManager
    public let motionManager: MotionManager
    public let locationManager: LocationManager
    public let networkManager: NetworkManager
    
    var isRecording: Bool = false
    var isRecordingPaused: Bool = false
    private (set) public var previousLocation: CLLocation?
    
    var onPit: ((_ pitValue: Double) -> ())?
    var onMotionStart: ((_ value: Double, _ filtered: Bool) -> ())?
    var onMotionStop: (() -> ())?
    var onMotionResume: (() -> ())?
    var onMotionPause: (() -> ())?
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
        
        onMotionCompleted = { [unowned self] in
            self.handleMotionCompletedEvent()
        }
    }
    
    
    // MARK: Public funcs
    
    func startRecording() {
        if !LocationManager.isEnable() {
            if UIApplication.shared.applicationState != .active {
                LocalNotificationManager.sendNotificationIfLocationDisabled()
            }
            AlertManager.showAlertLocationNotAuthorized(false)
            return
        }
        isRecording = true
        locationManager.requestLocation()
        motionManager.startRecording()
        onLocation?()
    }
    
    func stopRecording() {
        isRecording = false
        locationManager.stopUpdatingLocationIfNeeded()
        onMotionStop?()
        motionManager.stopRecording()
    }
    
    func pauseRecording() {
        isRecording = false
        locationManager.stopUpdatingLocationIfNeeded()
        motionManager.pauseRecording()
        onMotionPause?()
    }
    
    func resumeRecording() {
        if !LocationManager.isEnable() {
            if UIApplication.shared.applicationState != .active {
                LocalNotificationManager.sendNotificationIfLocationDisabled()
            }
            AlertManager.showAlertLocationNotAuthorized(false)
            return
        }
        isRecording = true
        locationManager.requestLocation()
        motionManager.resumeRecording()
        onMotionResume?()
    }
    
    
    // MARK: Private funcs
    
    private func appendNewPit(with location: CLLocation, tag: PitTag) {
        let pit = PitModel(location: location,
                           tag: tag,
                           accelerometerData: motionManager.getAccelerometerData())
        
        dbManager.update {
            motionManager.track?.pits.append(pit)
        }
        dbManager.add(motionManager.track)
    }
    
    private func updateTrack(with newLocation: CLLocation) {
        if let previous = self.previousLocation {
            let extraDistance = newLocation.distance(from: previous)
            self.dbManager.update {
                motionManager.track?.distance += CGFloat(extraDistance)
            }
            self.dbManager.add(motionManager.track)
            
            let distance = Double(motionManager.track?.distance ?? 0)
            
            trackDistanceUpdated?(distance)
            if let newPit = motionManager.track?.pits.last {
                maxPitUpdated?(newPit.value)
            }
        }
    }
    
    private func handleUpdateLocationEvent() {
        if let newLocation = locationManager.currentLocation {
            appendNewPit(with: newLocation, tag: .cp)
            updateTrack(with: newLocation)

            previousLocation = newLocation
        }
    }
    
    private func handleMotionCompletedEvent() {
        guard let currLocation = locationManager.currentLocation else { return }
        appendNewPit(with: currLocation, tag: .cp)
        
        let pred = NSPredicate(format: "status == 0")
        let result = self.dbManager.objects(type: TrackModel.self)?.filter(pred)
        if let result = result, result.count > 0 {
            updateCompletedTracks(result)
        }
        
        if SettingsManager.sharedInstance.sendTracksAutomatically == true {
            SendTracksService.shared.sendAllNotPostedTraks()
        }
    }
    
    private func updateCompletedTracks(_ tracks: Results<TrackModel>) {
        self.dbManager.update {
            for item in tracks {
                item.status = TrackStatus.waitingForUpload.rawValue
            }
        }
    }
    
    private func handleOnPitEvent(pitValue: Double) {
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
        pit.tag = PitTag.origin.rawValue
        pit.horizontalAccuracy = locationManager.currentLocation?.horizontalAccuracy ?? 0.0
        pit.speed = locationManager.currentLocation?.speed ?? 0.0
        
        self.dbManager.update {
            self.motionManager.track?.pits.append(pit)
        }
        self.dbManager.add(self.motionManager.track)
        
        maxPitUpdated?(pitValue)
    }
    
}




