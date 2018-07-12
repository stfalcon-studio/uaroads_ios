//
//  RouteBuildHelper.swift
//  UARoads_swift
//
//  Created by Andrew Yaniv on 7/12/18.
//  Copyright © 2018 Victor Amelin. All rights reserved.
//

import UIKit
import Mapbox
import MapboxNavigation
import MapboxDirections
import MapboxCoreNavigation

class RouteBuildHelper: NSObject {

    class func route(from originCoordinates: CLLocationCoordinate2D, to destinationCoordinates: CLLocationCoordinate2D, completion: @escaping (Route?) -> ()) {
        let origin = Waypoint(coordinate: originCoordinates, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destinationCoordinates, coordinateAccuracy: -1, name: "Finish")
        
        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
        
        _ = Directions.shared.calculate(options) { (waypoints, routes, error) in
            if let sRoutes = routes {
                completion(sRoutes.first)
            } else {
                completion(nil)
            }
        }
    }
    
}
