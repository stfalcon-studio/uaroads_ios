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
    var isRequestingLocation = false
    
    //event
    var onLocationUpdate: ((_ location: CLLocation) -> ())?
    
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
        isRequestingLocation = true
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
        isRequestingLocation = false
    }
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if let onLocUpldate = self.onLocationUpdate {
            onLocUpldate(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        pl("ERROR: \(error.localizedDescription)")
        if isRequestingLocation == true {
            requestLocation()
        }
    }
}






