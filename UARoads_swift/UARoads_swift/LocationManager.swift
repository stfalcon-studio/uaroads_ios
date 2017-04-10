//
//  LocationManager.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/10/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private override init() {}
    static let sharedInstance = LocationManager()
    override func copy() -> Any {
        fatalError("don`t use copy!")
    }
    
    override func mutableCopy() -> Any {
        fatalError("don`t use copy!")
    }
    
    //========================
    
    fileprivate let manager = CLLocationManager()
    
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
        lastLocationCoord = locations.last?.coordinate
    }
}









