//
//  LocationManager.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/24/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    override init() {
        super.init()
        
        manager.delegate = self
        manager.pausesLocationUpdatesAutomatically = false
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.allowsBackgroundLocationUpdates = true
        manager.activityType = .automotiveNavigation
        manager.requestAlwaysAuthorization()
    }

    let manager = CLLocationManager()

    //event
    var onLocationUpdate: ((_ locations: [CLLocation]) -> ())?
    
    func requestLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations as Any)
        onLocationUpdate?(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription)")
    }
}
