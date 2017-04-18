//
//  AppDelegate.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import UHBConnectivityManager
import StfalconSwiftExtensions

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var fetchCompletionHandler: ((UIBackgroundFetchResult) -> Void)?
    private var backgroundTrackSendingCompleted: Bool = false
    
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
        
        //connection check
        UHBConnectivityManager.shared().registerCallBack({ (status: ConnectivityManagerConnectionStatus) in
            if status == ConnectivityManagerConnectionStatusConnected {
                print("Internet connected")
            } else {
                print("No connection")
            }
        }, forIdentifier: self.memoryAddress())
        
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

















