//
//  NetworkConnectionManager.swift
//  UARoads_swift
//
//  Created by Roman on 7/27/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import UHBConnectivityManager


class NetworkConnectionManager {
    static let shared = NetworkConnectionManager()
    private init() {}
    
    
    func startMonitoring() {
        UHBConnectivityManager.shared().registerCallBack({ (status: ConnectivityManagerConnectionStatus) in
            pl(status)
        }, forIdentifier: String(describing: type(of: self)))
    }
    
    func stopMonitoring() {
        UHBConnectivityManager.shared().removeCallBack(forIdentitfier: String(describing: type(of: self)))
    }
    
}
