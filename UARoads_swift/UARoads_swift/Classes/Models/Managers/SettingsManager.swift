//
//  SettingsManager.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/13/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation

enum SettingsKeys: String {
    case sendDataOnlyWiFi = "sendDataOnlyWiFiKey"
    case routeRecordingAutostart = "routeRecordingAutostartKey"
    case showGraph = "showGraphKey"
    case sendTracksAutomatically = "sendTracksAutomaticallyKey"
    case email = "emailKey"
    case enableSound = "enableSoundKey"
    case firstLaunch = "firstLaunchKey"
}

final class SettingsManager {
    private init() {}
    static let sharedInstance = SettingsManager()
    
    private let defaults = UserDefaults.standard
    
    var sendDataOnlyWiFi: Bool {
        get { return defaults.bool(forKey: SettingsKeys.sendDataOnlyWiFi.rawValue) }
        set { defaults.set(newValue, forKey: SettingsKeys.sendDataOnlyWiFi.rawValue); defaults.synchronize() }
    }
    
    var routeRecordingAutostart: Bool {
        get { return defaults.bool(forKey: SettingsKeys.routeRecordingAutostart.rawValue) }
        set { defaults.set(newValue, forKey: SettingsKeys.routeRecordingAutostart.rawValue); defaults.synchronize() }
    }
    
    var sendTracksAutomatically: Bool {
        get {
            return defaults.bool(forKey: SettingsKeys.sendTracksAutomatically.rawValue)
        } set {
            defaults.set(newValue, forKey: SettingsKeys.sendTracksAutomatically.rawValue)
        }
    }
    
    var enableSound: Bool {
        get { return defaults.bool(forKey: SettingsKeys.enableSound.rawValue) }
        set { defaults.set(newValue, forKey: SettingsKeys.enableSound.rawValue); defaults.synchronize() }
    }
    
    var email: String? {
        get { return defaults.string(forKey: SettingsKeys.email.rawValue) }
        set { defaults.set(newValue, forKey: SettingsKeys.email.rawValue); defaults.synchronize()  }
    }
    
    var firstLaunch: String? {
        get { return defaults.string(forKey: SettingsKeys.firstLaunch.rawValue) }
        set { defaults.set(newValue, forKey: SettingsKeys.firstLaunch.rawValue); defaults.synchronize()  }
    }
    
    
    func setDefaultSetting() {
        self.sendDataOnlyWiFi = true
        self.sendTracksAutomatically = true
        self.routeRecordingAutostart = false
    }
}




