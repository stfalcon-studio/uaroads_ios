//
//  TrackModel.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/11/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

enum TrackStatus {
    case active
    case saved
    case waitingForUpload
    case uploading
    case uploaded
}

struct TrackModel {
    var trackID: String?
    var title: String?
    var date: Date?
    var status: TrackStatus?
    var distance: CGFloat?
    var maxPit: CGFloat?
    
    var pits: [Any]?
    var autoRecord: Bool?
    var debug: Bool?
    var trackFileName: String?
}






