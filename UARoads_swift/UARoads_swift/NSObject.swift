//
//  ViewController.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/18/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UserNotifications

extension NSObject {
    public func addNotification(text: String, time: TimeInterval, sound: String? = nil) {
        //create and add local user notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Date().addingTimeInterval(1.0).timeIntervalSinceNow,
                                                        repeats: false)
        
        let content = UNMutableNotificationContent()
        content.body = NSLocalizedString(text, comment: "")
        content.title = NSLocalizedString("UARoads", comment: "noteTitle")
        if let sound = sound {
            content.sound = UNNotificationSound(named: sound)
        }
        
        let request = UNNotificationRequest(identifier: "uaroads", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
