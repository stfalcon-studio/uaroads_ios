//
//  LocationManager.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/10/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    private override init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.distanceFilter = 0
        manager.activityType = CLActivityType(rawValue: Int(kCLLocationAccuracyBestForNavigation))!
        manager.allowsBackgroundLocationUpdates = true
        manager.startMonitoringSignificantLocationChanges() //TODO: depending on autostart
        manager.delegate = self
        manager.requestAlwaysAuthorization()
    }
    static let sharedInstance = LocationManager()
    override func copy() -> Any {
        fatalError("don`t use copy!")
    }
    override func mutableCopy() -> Any {
        fatalError("don`t use copy!")
    }
    
    //========================
    
    var completionHandler: EmptyHandler?
    let manager = CLLocationManager()
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            let autoManager = AutostartManager.sharedInstance
            let speed = lastLocation.speed
            let hAccuracy = lastLocation.horizontalAccuracy
            
            completionHandler?()
            
            if MotionManager.sharedInstance.status == .notActive || autoManager.status == 2 {
                switch autoManager.status {
                case 0:
                    autoManager.beginCheckForAutostart()
                    
                case 1:
                    if speed > autoManager.Min_speed_to_start_recording && hAccuracy < 20 {
                        autoManager.lastMaxSpeed = lastLocation.speed
                        autoManager.startRecording()
                    }
                    
                case 2:
                    if speed > autoManager.lastMaxSpeed && hAccuracy < 20 {
                        autoManager.lastMaxSpeed = lastLocation.speed
                    }
                    
                default: break
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription)")
    }
}









