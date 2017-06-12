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
    
    // MARK: Properties
    private let manager = CLLocationManager()
    var currentLocation: CLLocation? {
        get {
            return manager.location
        }
    }
    
    //event
    // TODO: delete or uncomment
//    var onLocationUpdate: ((_ locations: [CLLocation]) -> ())?
    
    // MARK: Init funcs
    override init() {
        super.init()
        
        manager.delegate = self
        manager.pausesLocationUpdatesAutomatically = false
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.allowsBackgroundLocationUpdates = true
        manager.activityType = .automotiveNavigation
        manager.requestAlwaysAuthorization()
        
    }

    // MARK: Public funcs
    
    func requestLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        pf()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        pl("ERROR: \(error.localizedDescription)")
    }
}






