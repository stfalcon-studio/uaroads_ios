//
//  SimplePitModel.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/12/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import CoreLocation
import CoreMotion

struct SimplePitModel {
    var location: CLLocation?
    var accelerometerData: CMAccelerometerData?
    var time: Date?
    var value: Double?
    var tag: String?
    var debug: Bool?
}








