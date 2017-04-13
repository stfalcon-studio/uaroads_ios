//
//  TrackModel.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/11/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import RealmSwift

enum TrackStatus: Int {
    case active
    case saved
    case waitingForUpload
    case uploading
    case uploaded
    
    func title() -> String {
        switch self {
        case .active: return "Active"
        case .saved: return "Saved"
        case .waitingForUpload: return "WaitingForUpload"
        case .uploading: return "Uploading"
        case .uploaded: return "Uploaded"
        }
    }
}

class TrackModel: Object {
    dynamic var trackID: String = ""
    dynamic var title: String = ""
    dynamic var date: Date = Date()
    dynamic var distance: CGFloat = 0.0
    dynamic var maxPit: CGFloat = 0.0
    dynamic var status = TrackStatus.active.rawValue
    dynamic var autoRecord: Bool = false
    dynamic var debug: Bool = false
    dynamic var trackFileName: String = ""
    var pits: [String] {
        get { return self.pits }
        set { self.pits = newValue }
    }
    
    override static func primaryKey() -> String? {
        return "trackID"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["pits"]
    }
}






