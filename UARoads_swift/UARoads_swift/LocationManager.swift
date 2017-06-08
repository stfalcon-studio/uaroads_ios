//
//  LocationManager.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/24/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    override init() {
        super.init()
        
        manager.delegate = self
        manager.pausesLocationUpdatesAutomatically = false
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.allowsBackgroundLocationUpdates = true
        manager.activityType = .automotiveNavigation
        manager.requestAlwaysAuthorization()
    }

    private let manager = CLLocationManager()

    var currentLocation: CLLocationCoordinate2D? {
        get {
            return manager.location?.coordinate
        }
    }
    
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
        pl(locations)
        pl(locations.first?.coordinate)
        onLocationUpdate?(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        pl("ERROR: \(error.localizedDescription)")
    }
}






