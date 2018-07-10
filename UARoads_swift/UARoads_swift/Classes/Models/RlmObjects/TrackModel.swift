//
//  TrackModel.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/11/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import RealmSwift

class TrackModel: Object {
    @objc dynamic var trackID: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var date: Date = Date()
    @objc dynamic var distance: CGFloat = 0.0
    @objc dynamic var maxPit: Double = 0.0
    @objc dynamic var status = TrackStatus.active.rawValue
    @objc dynamic var autoRecord: Bool = false
    @objc dynamic var debug: Bool = false
    @objc dynamic var trackFileName: String = ""
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
            "auto_record" : autorecord as AnyObject
        ]
        
        return params
    }
//    func sendTrackParametersString() -> [String : String] {
//        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
//        let autorecord = self.autoRecord ? 1 : 0
//        let params: [String : String] = [
//            "uid": Utilities.deviceUID(),
//            "comment":self.title,
//            "routeId":self.trackID,
//            "data": data64 as AnyObject,
//            "app_ver":version,
//            "auto_record" : String(autorecord),
//        ]
//        
//        return params
//    }
    
}


enum TrackStatus: Int {
    case active
    case saved
    case waitingForUpload
    case uploading
    case uploaded
    
    func title() -> String {
        switch self {
        case .active: return "TrackStateActive".localized
        case .saved: return "TrackStateSaved".localized
        case .waitingForUpload: return "TrackStateWait".localized
        case .uploading: return "TrackStateUploading".localized
        case .uploaded: return "TrackStateUploaded".localized
        }
    }
}



