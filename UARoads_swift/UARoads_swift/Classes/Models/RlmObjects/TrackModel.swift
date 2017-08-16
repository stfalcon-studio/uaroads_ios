//
//  TrackModel.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/11/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import RealmSwift

class TrackModel: Object {
    dynamic var trackID: String = ""
    dynamic var title: String = ""
    dynamic var date: Date = Date()
    dynamic var distance: CGFloat = 0.0
    dynamic var maxPit: Double = 0.0
    dynamic var status = TrackStatus.active.rawValue
    dynamic var autoRecord: Bool = false
    dynamic var debug: Bool = false
    dynamic var trackFileName: String = ""
    let pits = List<PitModel>()
    
    override static func primaryKey() -> String? {
        return "trackID"
    }
    
    func deletePits() {
        let realm = try? Realm()
        try! realm?.write({
            realm?.delete(self.pits)
        })
    }
    
    func sendTrackParameters() -> [String : AnyObject] {
        let data64: String = TracksFileManager.trackStringData(from: self)
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let autorecord = self.autoRecord ? 1 : 0
        let params: [String : AnyObject] = [
            "uid": Utilities.deviceUID() as AnyObject,
            "comment":self.title as AnyObject,
            "routeId":self.trackID as AnyObject,
            "data": data64 as AnyObject,
            "app_ver":version as AnyObject,
            "auto_record" : autorecord as AnyObject,
            "date":"\(self.date.timeIntervalSince1970)" as AnyObject
        ]
        
        return params
    }
    
}


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
        case .waitingForUpload: return "Waiting For Upload"
        case .uploading: return "Uploading"
        case .uploaded: return "Uploaded"
        }
    }
}



