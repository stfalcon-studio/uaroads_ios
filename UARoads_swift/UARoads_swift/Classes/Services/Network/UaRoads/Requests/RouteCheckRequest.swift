//
//  RouteCheckRequest.swift
//  UARoads_swift
//
//  Created by Max Vasilevsky on 11/6/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import CoreLocation

class RouteCheckRequest: BaseRequest {
    var coord1 = CLLocationCoordinate2D()
    var coord2 = CLLocationCoordinate2D()

    override func apiPath() -> String {
        return "/viaroute?output=json&instructions=false&geometry=false&alt=false&loc=\(coord1.latitude),\(coord1.longitude)&loc=\(coord2.latitude),\(coord2.longitude)"
    }
    
    override func baseURL() -> ApiPath {
        return .routePath
    }
    
//    override func parameters() -> [String : Any] {
//        return ["output":"json",
//        "instructions":"false",
//        "geometry":"false",
//        "loc":"\(coord1.latitude),\(coord1.longitude)",
//        "loc1":"\(coord2.latitude),\(coord2.longitude)"]
//    }
    
//    var request = URLRequest(url: URL(string: "http://route.uaroads.com/viaroute?output=json&instructions=false&geometry=false&alt=false&loc=\(coord1.latitude),\(coord1.longitude)&loc=\(coord2.latitude),\(coord2.longitude)")!)
    
    
    
}
