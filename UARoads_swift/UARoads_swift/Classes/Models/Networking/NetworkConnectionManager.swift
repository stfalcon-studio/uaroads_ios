//
//  NetworkConnectionManager.swift
//  UARoads_swift
//
//  Created by Roman on 7/27/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import SystemConfiguration
import ReachabilitySwift


let networkStatusChangedNotification = "networkStatusChangedNotification"

class NetworkConnectionManager {
    static let shared = NetworkConnectionManager()
    private let reachability = Reachability()!
    private (set) public var networkStatus: ReachabilityStatus = .notReachable
    
    enum ReachabilityStatus {
        case notReachable
        case reachableViaCellular
        case reachableViaWiFi
    }
    
    private init() {}
    
    deinit {
        stopMonitoring()
    }
    
    
    
    func startMonitoring() {
        do{
            try reachability.startNotifier()
        }catch{
            pl("could not start reachability notifier")
            pl("error -> \(error.localizedDescription)")
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(networkStatusChanged(notification:)),
                                               name: ReachabilityChangedNotification,
                                               object: reachability)
    }
    
    func stopMonitoring() {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self,
                                                  name: ReachabilityChangedNotification,
                                                  object: reachability)
    }
    
    
    @objc func networkStatusChanged(notification: Notification) {
        guard let reachability = notification.object as? Reachability else { return }
        
        if reachability.isReachable {
            if reachability.isReachableViaWiFi {
                networkStatus = ReachabilityStatus.reachableViaWiFi
                pl("Reachable via WiFi")
            } else {
                pl("Reachable via Cellular")
                networkStatus = ReachabilityStatus.reachableViaCellular
            }
        } else {
            pl("Network not reachable")
            networkStatus = ReachabilityStatus.notReachable
        }
        
        let notificationName = Notification.Name(networkStatusChangedNotification)
        NotificationCenter.default.post(name: notificationName, object: networkStatus)
    }
    
}
