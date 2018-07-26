//
//  Constants.swift
//  UARoads_swift
//
//  Created by Roman Rybachenko on 7/4/17.
//  Copyright © 2017 UARoads. All rights reserved.
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

enum ReachabilityStatus {
    case notReachable
    case reachableViaCellular
    case reachableViaWiFi
}

enum MotionActivity {
    case stationary
    case walking
    case running
    case automotive
    case cycling
    case unknown
}

enum RecordStatus {
    case notActive
    case active
    case paused
    case pausedForCall
}

enum TabbarItem: Int {
    case buildRoute
    case recordTrack
    case settings
    
    func title() -> String {
        var titleStr = ""
        switch self {
        case .buildRoute:
            titleStr = NSLocalizedString("tabbar.item.0", comment: "")
        case .recordTrack:
            titleStr = NSLocalizedString("tabbar.item.1", comment: "")
        case .settings:
            titleStr = NSLocalizedString("tabbar.item.3", comment: "")
        }
        
        return titleStr
    }
}



