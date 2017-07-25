//
//  CLLocation.swift
//  UARoads_swift
//
//  Created by Roman Rybachenko on 7/4/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    class func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        
        return fromLocation.distance(from: toLocation)
    }
}
