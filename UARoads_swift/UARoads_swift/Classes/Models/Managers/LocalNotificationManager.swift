//
//  LocalNotificationManager.swift
//  UARoads_swift
//
//  Created by Max Vasilevsky on 11/21/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import UserNotifications


class LocalNotificationManager {
    
    class func checkNotificationAuthorization(_ completion:@escaping (Bool) -> ()){
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (success, error) in
                completion(success)
            }
        } else {
            let notificationTypes: UIUserNotificationType = [.alert , .sound]
            let newNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(newNotificationSettings)
            if let settings = UIApplication.shared.currentUserNotificationSettings {
                if settings.types.contains([.alert]) {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    class func sendNotificationIfLocationDisabled() {
        let content = UNMutableNotificationContent()
        content.title = "Warning".localized
        content.body = "Notification.locationServiceDisabled".localized
        content.categoryIdentifier = "message"
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "2", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    
}
