//
//  PitModel.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/12/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import RealmSwift

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
}
