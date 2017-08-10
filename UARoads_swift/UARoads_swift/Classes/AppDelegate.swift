//
//  AppDelegate.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import UserNotifications
import StfalconSwiftExtensions

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var backgroundSessionCompletionHandler: (() -> Void)?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        NetworkConnectionManager.shared.startMonitoring()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        //background task
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        
        interfaceAppearance()
        
        //analytics
        AnalyticManager.sharedInstance.startAnalytics()
        if let email = SettingsManager.sharedInstance.email {
            AnalyticManager.sharedInstance.identifyUser(email: email, name: nil)
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            if SettingsManager.sharedInstance.firstLaunch != nil {
                window.rootViewController = TabBarVC()
            } else {
                window.rootViewController = TutorialVC()
                SettingsManager.sharedInstance.setDefaultSetting()
            }
            window.makeKeyAndVisible()
        }
        
        AutostartManager.shared.switchAutostart(to: SettingsManager.sharedInstance.routeRecordingAutostart)
        
        //notifications
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, _) in
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            }
        })
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first!
        pl("Documents directory path: \n\(documentsUrl)")
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        
        backgroundSessionCompletionHandler = completionHandler
        
        let networkStatus = NetworkConnectionManager.shared.networkStatus
        let isWiFiOnly = SettingsManager.sharedInstance.sendDataOnlyWiFi
        
        if (isWiFiOnly == true && networkStatus == .reachableViaWiFi) ||
            (isWiFiOnly == false && networkStatus != .notReachable) {
            
            SendTracksService.shared.sendAllNotPostedTraks()
        }
    }
    
    
    //MARK: Helpers
    private func interfaceAppearance() {
        //navigation bar appearance
        let navBar = UINavigationBar.appearance()
        navBar.isTranslucent = false
        navBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navBar.barTintColor = UIColor.colorPrimary
        
        //tabBar appearance
        let tabBar = UITabBar.appearance()
        tabBar.isTranslucent = false
    }
    

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let note = notification.request.content.userInfo
        
        print(note)
        
        completionHandler([.sound, .alert, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print(response.notification.request.content.userInfo)
    }
}


