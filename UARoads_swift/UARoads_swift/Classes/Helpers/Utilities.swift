//
//  Utilities.swift
//  UARoads_swift
//
//  Created by Roman Rybachenko on 7/17/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation




class Utilities {
    
    class func deviceUID() -> String {
        var uid: String? = UserDefaults.standard.string(forKey: kDeviceUID)
        if uid == nil {
            uid = UIDevice.current.identifierForVendor?.uuidString
            uid = uid?.appending("1")
            UserDefaults.standard.setValue(uid, forKey: kDeviceUID)
        }
        pl("deviceUID - \(uid!)")
        return uid!
    }
    
    class func appVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
}
