//
//  SearchGeoRequest.swift
//  UARoads
//
//  Created by Max Vasilevsky on 10/30/17.
//  Copyright © 2017 Max Vasilevsky. All rights reserved.
//

import UIKit
import CoreLocation

class SearchGeoRequest: BaseRequest {
    
    var locationName = ""
    var coordinate = CLLocationCoordinate2D()
    
    override func parameters() -> [String : Any] {
        return ["lang":"uk_UA",
                "format":"json",
                "ll":"\(coordinate.latitude), \(coordinate.longitude)",
                "geocode":"Україна, \(locationName)"]
    }
    
    override func baseURL() -> ApiPath {
        return .geoPath
    }
    
    
    override func type() -> RequestType {
        return .searchLocation
    }

}
