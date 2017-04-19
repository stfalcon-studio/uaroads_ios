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
        UARoadsSDK.sharedInstance.sendDataActivity()
    }
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //background task
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        deleteOldTracks()
        
        interfaceAppearance()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.rootViewController = TabBarVC()
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
        
//        //connection check
//        UHBConnectivityManager.shared().registerCallBack({ (status: ConnectivityManagerConnectionStatus) in
//            if status == ConnectivityManagerConnectionStatusConnected {
//                print("Internet connected")
//            } else {
//                print("No connection")
//            }
//        }, forIdentifier: self.memoryAddress())
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        fetchCompletionHandler = completionHandler
        
        backgroundTrackSendingCompleted = false
        if MotionManager.sharedInstance.status == .notActive {
            sendDataActivity()
        } else {
            completeBackgroundTrackSending(false)
        }
    }
    
    //MARK: Helpers
    private func interfaceAppearance() {
        //navigation bar appearance
        let navBar = UINavigationBar.appearance()
        navBar.isTranslucent = false
        navBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        navBar.barTintColor = UIColor.navBar
        
        //tabBar appearance
        let tabBar = UITabBar.appearance()
        tabBar.isTranslucent = false
    }
    
    private func sendDataActivity() {
        UARoadsSDK.sharedInstance.sendDataActivity()
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

















