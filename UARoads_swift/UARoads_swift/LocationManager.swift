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
    private override init() {}
    static let sharedInstance = LocationManager()
    override func copy() -> Any {
        fatalError("don`t use copy!")
    }
    
    override func mutableCopy() -> Any {
        fatalError("don`t use copy!")
    }
    
    //========================
    
    let manager = CLLocationManager()
    var lastLocationCoord: CLLocationCoordinate2D?
    
    func start() {
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.distanceFilter = 0
        manager.activityType = CLActivityType(rawValue: Int(kCLLocationAccuracyBestForNavigation))!
        manager.allowsBackgroundLocationUpdates = true
        manager.startMonitoringSignificantLocationChanges() //TODO: depending on autostart
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        
        manager.startUpdatingLocation()
    }
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last as Any)
        lastLocationCoord = locations.last?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription)")
    }
}









