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
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var time: String = ""
    @objc dynamic var value: Double = 0.0
    @objc dynamic var tag: String = ""
    @objc dynamic var horizontalAccuracy: Double = 0.0
    @objc dynamic var speed: Double = 0.0
    
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
