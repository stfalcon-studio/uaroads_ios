//
//  AppDelegate.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import UserNotifications
import UHBConnectivityManager
import StfalconSwiftExtensions

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var fetchCompletionHandler: ((UIBackgroundFetchResult) -> Void)?
    private var backgroundTrackSendingCompleted: Bool = false
    private let sendDataActivityTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { (_) in
        (UIApplication.shared.delegate as? AppDelegate)?.sendDataActivity()
    }
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        NetworkConnectionManager.shared.startMonitoring()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        //autostart check
        AutostartManager.sharedInstance.setAutostartActive(SettingsManager.sharedInstance.routeRecordingAutostart)
        
        //background task
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        
        interfaceAppearance()
        
        //analytics
        AnalyticManager.sharedInstance.startAnalytics()
        if let email = SettingsManager.sharedInstance.email {
            AnalyticManager.sharedInstance.identifyUser(email: email, name: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            AnalyticManager.sharedInstance.reportEvent(category: "System", action: "Launch completeActiveTracks", label: nil, value: nil)
            self?.sendDataActivity()
            self?.deleteOldTracks()
            
            AnalyticManager.sharedInstance.reportEvent(category: "System", action: "Launch after completeActiveTracks", label: nil, value: nil)
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            if SettingsManager.sharedInstance.firstLaunch != nil {
                window.rootViewController = TabBarVC()
            } else {
                window.rootViewController = TutorialVC()
            }
            window.makeKeyAndVisible()
        }
        
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
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        fetchCompletionHandler = completionHandler
        backgroundTrackSendingCompleted = false
        if RecordService.sharedInstance.motionManager.status == .notActive {
            sendDataActivity()
        } else {
            completeBackgroundTrackSending(false)
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
//         SendTracksService.shared.sendAllNotPostedTraks()
    }
    
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        
        backgroundSessionCompletionHandler = completionHandler
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
    
    func sendDataActivity() {
        // TODO: Delete UHBConnectivityManager and code which is bound with that.
        
        //check any connection
        if UHBConnectivityManager.shared().isConnected() == true {
            //check settings
            if SettingsManager.sharedInstance.sendDataOnlyWiFi == true {
                //check wifi connection
                if UHBConnectivityManager.shared().isConnectedOverMobileData() == false {
                    RecordService.sharedInstance.onSend?()
                    return
                }
            }
            RecordService.sharedInstance.onSend?()
        }
    }
    
    func completeBackgroundTrackSending(_ val: Bool) {
        backgroundTrackSendingCompleted = val
        fetchCompletion(val)
    }
    
    private func fetchCompletion(_ val: Bool) {
        if backgroundTrackSendingCompleted == true && fetchCompletionHandler != nil {
            UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
            if val {
                fetchCompletionHandler?(.newData)
            } else {
                fetchCompletionHandler?(.noData)
            }
            fetchCompletionHandler = nil
        }
    }
    
    private func deleteOldTracks() {
        AnalyticManager.sharedInstance.reportEvent(category: "System", action: "Before old tracks delete", label: nil, value: nil)
        //check connection first
        if UHBConnectivityManager.shared().isConnected() == true {
            let pred = NSPredicate(format: "status == 4")
            let result = RealmHelper.objects(type: TrackModel.self)?.filter(pred)
            if let result = result {
                for item in result {
                    item.delete()
                }
            }
        }
        AnalyticManager.sharedInstance.reportEvent(category: "System", action: "Old tracks deleted", label: nil, value: nil)
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

















