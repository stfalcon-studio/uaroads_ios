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
    
//    var completionHandler: EmptyHandler?
    let manager = CLLocationManager()
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        completionHandler?() //TODO: check this!
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: Note.locationUpdate.rawValue), object: locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription)")
    }
}









