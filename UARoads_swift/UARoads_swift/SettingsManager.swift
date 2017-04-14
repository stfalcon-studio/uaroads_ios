//
//  SettingsManager.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/13/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation

enum Constants: String {
    case sendDataOnlyWiFi = "sendDataOnlyWiFiKey"
    case routeRecordingAutostart = "routeRecordingAutostartKey"
    case showGraph = "showGraphKey"
    case email = "emailKey"
}

final class SettingsManager {
    private init() {}
    static let sharedInstance = SettingsManager()
    
    private let defaults = UserDefaults.standard
    
    var sendDataOnlyWiFi: Bool {
        get { return defaults.bool(forKey: Constants.sendDataOnlyWiFi.rawValue) }
        set { defaults.set(newValue, forKey: Constants.sendDataOnlyWiFi.rawValue); defaults.synchronize() }
    }
    
    var routeRecordingAutostart: Bool {
        get { return defaults.bool(forKey: Constants.routeRecordingAutostart.rawValue) }
        set { defaults.set(newValue, forKey: Constants.routeRecordingAutostart.rawValue); defaults.synchronize() }
    }
    
    var showGraph: Bool {
        get { return defaults.bool(forKey: Constants.showGraph.rawValue) }
        set { defaults.set(newValue, forKey: Constants.showGraph.rawValue); defaults.synchronize() }
    }
    
    var email: String? {
        get { return defaults.string(forKey: Constants.email.rawValue) }
        set { defaults.set(newValue, forKey: Constants.email.rawValue) }
    }
}
