
//
//  AppDelegate.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 UARoads. All rights reserved.
//

import UIKit
import UserNotifications

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
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            }
        })
        
        let documentsUrl = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first!
        pl("Documents directory path: \n\(documentsUrl)")
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let bool = handleQuickAction(shortcutItem)
        completionHandler(bool)
    }
    
    func configureShortCutItems(forKillApp:Bool) {
        let recordTitle = RecordService.shared.isRecording && !forKillApp ? "ShortCut.item.1.forPause".localized : "ShortCut.item.1.forStart".localized
        let recordIcon = UIApplicationShortcutIcon(templateImageName: "record-normal")
        let recordItem = UIMutableApplicationShortcutItem(type: Shortcut.changeRecordState.rawValue, localizedTitle: recordTitle,
                                                          localizedSubtitle: nil, icon: recordIcon, userInfo: nil)

        let settingsIcon = UIApplicationShortcutIcon(templateImageName: "settings-normal")
        let settingsItem = UIMutableApplicationShortcutItem(type: Shortcut.openSettings.rawValue,
                                                            localizedTitle: "ShortCut.item.3".localized,
                                                            localizedSubtitle: nil,
                                                            icon: settingsIcon, userInfo: nil)
        UIApplication.shared.shortcutItems = [settingsItem, recordItem]
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        configureShortCutItems(forKillApp: true)
    }
    
    enum Shortcut: String {
        case changeRecordState = "startRecord"
        case openSettings = "settings"
    }
    
    func handleQuickAction(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        let tabbar = window?.rootViewController as? TabBarVC
        var quickActionHandled = false
        if let shortcutType = Shortcut.init(rawValue: shortcutItem.type) {
            quickActionHandled = true
            switch shortcutType {
                case .changeRecordState:
                    tabbar?.selectedIndex = 1
                    RecordService.shared.isRecording ? RecordService.shared.stopRecording() : RecordService.shared.startRecording()
                case .openSettings:
                    tabbar?.selectedIndex = 2
            }
        }
        
        return quickActionHandled
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        configureShortCutItems(forKillApp: false)
        if SettingsManager.sharedInstance.routeRecordingAutostart && !LocationManager.isEnable() {
            LocalNotificationManager.sendNotificationIfLocationDisabled()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        sendTracksIfNeeded()
    }
    
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        
        backgroundSessionCompletionHandler = completionHandler
        
        sendTracksIfNeeded()
    }
    
    
    //MARK: Helpers
    private func interfaceAppearance() {
        //navigation bar appearance
        let navBar = UINavigationBar.appearance()
        navBar.isTranslucent = false
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        navBar.barTintColor = UIColor.colorPrimary
        
        //tabBar appearance
        let tabBar = UITabBar.appearance()
        tabBar.isTranslucent = false
    }
    
    
    private func sendTracksIfNeeded() {
        let networkStatus = NetworkConnectionManager.shared.networkStatus
        let isWiFiOnly = SettingsManager.sharedInstance.sendDataOnlyWiFi
        
        if (isWiFiOnly == true && networkStatus == .reachableViaWiFi) ||
            (isWiFiOnly == false && networkStatus != .notReachable) {
            
            SendTracksService.shared.sendAllNotPostedTraks()
        }
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


