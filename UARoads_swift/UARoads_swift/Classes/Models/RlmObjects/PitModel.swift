//
//  PitModel.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/12/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import RealmSwift
import CoreLocation

class PitModel: Object, PitProtocol {
    dynamic var latitude: Double = 0.0
    dynamic var longitude: Double = 0.0
    dynamic var time: String = ""
    dynamic var value: Double = 0.0
    dynamic var tag: String = ""
    dynamic var horizontalAccuracy: Double = 0.0
    dynamic var speed: Double = 0.0
    
    override static func primaryKey() -> String? {
        return "time"
    }
    
    convenience init(location: CLLocation, tag: PitTag, accelerometerData: Double) {
        self.init()
        
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.horizontalAccuracy = location.horizontalAccuracy
        self.speed = location.speed
        self.time = "\(Date().timeIntervalSince1970 * 1000)"
        self.value = accelerometerData
        self.tag = tag.rawValue
    }
}
