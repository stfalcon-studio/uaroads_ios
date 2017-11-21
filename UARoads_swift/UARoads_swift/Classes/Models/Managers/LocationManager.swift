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
        setupBestDesiredAccuracy()
        manager.allowsBackgroundLocationUpdates = true
        manager.activityType = .automotiveNavigation
        manager.requestAlwaysAuthorization()
        
    }

    // MARK: Public funcs
    
    func setupBadDesiredAccuracy() {
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    func setupBestDesiredAccuracy() {
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    class func isEnable() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        } else {
            return false
        }
    }
    
    func requestLocation() {
        setupBestDesiredAccuracy()
        manager.startUpdatingLocation()
        isRequestingLocation = true
    }
    
    func stopUpdatingLocationIfNeeded() {
        let autostart = SettingsManager.sharedInstance.routeRecordingAutostart
        autostart ? setupBadDesiredAccuracy() : stopUpdatingLocation()
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



