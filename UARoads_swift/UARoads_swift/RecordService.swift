//
//  RecordService.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/21/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation

class RecordService {
    private init() {}
    static let sharedInstance = RecordService()
 
    //================
    
    public let dbManager = RealmManager()
    public let motionManager = MotionManager()
    
    func start() {
        //
    }
}
