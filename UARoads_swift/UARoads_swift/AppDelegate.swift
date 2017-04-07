//
//  AppDelegate.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import UHBConnectivityManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
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
                //                SocketManager.sharedInstance.reconnect()
                //                HUDManager.sharedInstance.hide()
                //                self?.popUpVC.dismiss()
                
            } else {
                print("No connection")
                //                SocketManager.sharedInstance.closeConnection()
            }
        }, forIdentifier: self.memoryAddress())
        
        return true
    }
    
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

