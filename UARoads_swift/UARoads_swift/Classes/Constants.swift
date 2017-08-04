//
//  Constants.swift
//  UARoads_swift
//
//  Created by Roman Rybachenko on 7/4/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation


let routeDistanceMin = 300

let PitInterval = 0.5

let updateLocationIntervalDefault = 1.0

let kDeviceUID = "DeviceUID"


enum GPS_Status: Int {
    case noSignal
    case low
    case middle
    case high
}

enum PitTag: String {
    case cp = "cp"
    case origin = "origin"
}



