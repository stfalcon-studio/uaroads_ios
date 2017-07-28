//
//  SendTracksService.swift
//  UARoads_swift
//
//  Created by Roman on 7/27/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import RealmSwift

class SendTracksService {
    static let sharedInstance = SendTracksService()
    
    private init() {}
    
    // MARK: Public funcs
    
    func sendAllNotPostedTraks() {
        if isSutableNetworkConnection() == false {
            return
        }
        
        guard let tracksToSend = allTracksToSend() else { return }
        
        
    }
    
    
    // MARK: Private funcs
    
    private func isSutableNetworkConnection() -> Bool {
        let sendDataOnlyWiFi = SettingsManager.sharedInstance.sendDataOnlyWiFi
        let currentNetwork = NetworkConnectionManager.shared.networkStatus
        
        if currentNetwork == .notReachable {
            return false
        }
        if sendDataOnlyWiFi && currentNetwork != .reachableViaWiFi {
            return false
        }
        
        return true
    }
    
    private func allTracksToSend() -> Results<TrackModel>? {
        let predicate = NSPredicate(format: "status = %@ OR status = %@",
                                    TrackStatus.saved.rawValue,
                                    TrackStatus.waitingForUpload.rawValue)
        
        let tracks = RealmManager().objects(type: TrackModel.self)?.filter(predicate)
        
        return tracks
    }
    
}


//private func handleOnSendEvent() {
//    AnalyticManager.sharedInstance.reportEvent(category: "System", action: "SendDataActivity Start")
//    
//    var sendingInProcess = false
//    
//    let pred = NSPredicate(format: "(status == 2) OR (status == 3)")
//    let result = self.dbManager.objects(type: TrackModel.self)?.filter(pred)
//    
//    if sendingInProcess == false {
//        if let result = result, result.count > 0 {
//            sendingInProcess = true
//            
//            if let track = result.first {
//                self.dbManager.update {
//                    track.status = TrackStatus.uploading.rawValue
//                }
//                
//                //prepare params for sending
//                let data64: String = TracksFileManager.trackStringData(from: track)//UARoadsSDK.encodePoints(Array(track.pits)) ?? ""
//                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
//                let autorecord = track.autoRecord ? 1 : 0
//                let params: [String : AnyObject] = [
//                    "uid": Utilities.deviceUID() as AnyObject,
//                    "comment":track.title as AnyObject,
//                    "routeId":track.trackID as AnyObject,
//                    "data": data64 as AnyObject,
//                    "app_ver":version as AnyObject,
//                    "auto_record" : autorecord as AnyObject,
//                    "date":"\(track.date.timeIntervalSince1970)" as AnyObject
//                ]
//                
//                NetworkManager.sharedInstance.tryToSendData(params: params, handler: { val in
//                    sendingInProcess = false
//                    
//                    if result.count > 1 && val  {
//                        self.onSend?() //recursion
//                    } else {
//                        (UIApplication.shared.delegate as? AppDelegate)?.completeBackgroundTrackSending(val)
//                    }
//                    
//                    self.dbManager.update {
//                        if val == true {
//                            track.status = TrackStatus.uploaded.rawValue
//                        } else {
//                            track.status = TrackStatus.waitingForUpload.rawValue
//                        }
//                    }
//                })
//            }
//        }
//    }
//    if !sendingInProcess {
//        (UIApplication.shared.delegate as? AppDelegate)?.completeBackgroundTrackSending(false)
//    }
//    AnalyticManager.sharedInstance.reportEvent(category: "System", action: "sendDataActivity End")
//}
