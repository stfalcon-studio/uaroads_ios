//
//  SendTracksService.swift
//  UARoads_swift
//
//  Created by Roman on 7/27/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import RealmSwift

class SendTracksService: NSObject, URLSessionDelegate {
    
    static let shared = SendTracksService()
    
    var urlSession: URLSession!
    
    private override init() {
        super.init()
        
        let opQueue = OperationQueue()
        opQueue.maxConcurrentOperationCount = 1
        let configuration = URLSessionConfiguration.default
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: opQueue)
    }
    
    // MARK: Public funcs
    
    func sendAllNotPostedTraks() {
        if isSutableNetworkConnection() == false {
            return
        }
        
        guard let tracksToSend = allTracksToSend() else { return }
        
        for track in tracksToSend {
            pl("trackId = \(track.trackID)")
        }
        
        for track in tracksToSend {
            sendTrack(track)
        }
    }
    
    func sendTrack(_ track: TrackModel) {
        let parameters = track.sendTrackParameters()
        var request = URLRequest(url: URL(string: "http://api.uaroads.com/add")!)
        request.httpMethod = "POST"
        request.httpBody = NSKeyedArchiver.archivedData(withRootObject: parameters)
        
        changeUploadStatus(.uploading, for: track)
        urlSession.dataTask(with: request) { [weak self] (data, response, error) in
            if let data = data {
                let result = String(data: data, encoding: String.Encoding.utf8)
                pl("RESULT: \(String(describing: result))")
                let uploadStatus: TrackStatus = result == "OK" ? .uploaded : .waitingForUpload
                DispatchQueue.main.async {
                    self?.changeUploadStatus(uploadStatus, for: track)
                }
            } else {
                pl(error)
            }
        }.resume()
    }
    
    
    // MARK: Private funcs
    
    private func changeUploadStatus(_ status: TrackStatus, for track: TrackModel) {
        RealmManager().update {
            track.status = status.rawValue
        }
    }
    
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
        let predicate = NSPredicate(format: "status = %ld OR status = %ld",
                                    TrackStatus.saved.rawValue,
                                    TrackStatus.waitingForUpload.rawValue)
        
        let tracks = RealmManager().objects(type: TrackModel.self)?.filter(predicate)
        
        return tracks
    }
    
    // MARK: Delegate funcs:
    // MARK: — URLSessionDelegate 
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        
    }
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        
    }
    
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
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
                //prepare params for sending
//                let data64: String = TracksFileManager.trackStringData(from: track)
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
