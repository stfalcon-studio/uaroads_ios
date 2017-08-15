//
//  SendTracksService.swift
//  UARoads_swift
//
//  Created by Roman on 7/27/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import RealmSwift

class SendTracksService: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    static let shared = SendTracksService()
    
    private (set) public var urlSession: URLSession!
    
    private (set) public var tracksToSend: [Dictionary<Int, ThreadSafeReference<UA_Roads.TrackModel>>] = []
    
    
    // MARK: Init funcs
    
    private override init() {
        super.init()
        
        let opQueue = OperationQueue.main
        opQueue.maxConcurrentOperationCount = 1
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSendTrackSessionConfiguration")
        self.urlSession = URLSession(configuration: configuration,
                                     delegate: self,
                                     delegateQueue: opQueue)
        
        let notificationName = Notification.Name(networkStatusChangedNotification)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(networkStatusChanged(_:)),
                                               name: notificationName,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Public funcs
    
    func sendAllNotPostedTraks() {
        if isSutableNetworkConnection() == false {
            return
        }
        
        guard let tracksResult = allTracksToSend() else { return }
        
        for track in tracksResult {
            pl("trackId = \(track.trackID)")
        }
        
        for track in tracksResult {
            sendTrack(track)
        }
    }
    
    func sendTrack(_ track: TrackModel) {
        let parameters = track.sendTrackParameters()
        pl(parameters)
        guard let sendTrackUrl = URL(string: "http://api.uaroads.com/add") else { return }
        var request = URLRequest(url: sendTrackUrl)
        request.httpMethod = "POST"
        let data = NSKeyedArchiver.archivedData(withRootObject: parameters)
        request.httpBody = data
        
        changeTrackStatus(.uploading, for: track)
        
        let task = urlSession.dataTask(with: request)
        
        let trackRef = ThreadSafeReference(to: track)
        let taskDict = [task.taskIdentifier : trackRef]
        
        tracksToSend.append(taskDict)
        
        task.resume()
    }
    
    
    // MARK: Notification observers
    
    func networkStatusChanged(_ notification: Notification) {
        guard let networkStatus = notification.object as? ReachabilityStatus else { return }
        
        if networkStatus == .reachableViaWiFi &&
            SettingsManager.sharedInstance.sendDataOnlyWiFi == true &&
            SettingsManager.sharedInstance.sendTracksAutomatically == true {
            
            sendAllNotPostedTraks()
        }
    }
    
    
    // MARK: Private funcs
    
    private func changeTrackStatus(_ status: TrackStatus, for track: TrackModel) {
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
    
    private func handleSendTrackResponse(with dataTask: URLSessionDataTask, trackStatus: TrackStatus) {
        DispatchQueue.main.async { [weak self] in
            guard let index = self?.tracksToSend.index(where: {
                $0.keys.first == dataTask.taskIdentifier
            }) else {
                return
            }
            
            guard let dict = self?.tracksToSend[index] else { return }
            guard let trackRef = dict[dataTask.taskIdentifier] else { return }
            guard let track = RealmManager().realm?.resolve(trackRef) else { return }
            
            self?.changeTrackStatus(trackStatus, for: track)
            
            self?.tracksToSend.remove(at: index)
        }
    }

    
    // MARK: Delegate funcs:
    // MARK: — URLSessionDelegate
    
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        pf()
        pl("urlSession error -> \(String(describing: error?.localizedDescription))")
    }
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        pf()
        let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        let authChallengeDisposition = Foundation.URLSession.AuthChallengeDisposition.useCredential
        completionHandler(authChallengeDisposition, credential)
    }
    
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        pl("background session \(session) finished events.")
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let completionHandler = appDelegate.backgroundSessionCompletionHandler {
            appDelegate.backgroundSessionCompletionHandler = nil
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }

    
    // MARK: — URLSessionDataDelegate
    
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        pf()
        pl("response -> \n\(response)")
        pl("dataTask id = \(dataTask.taskIdentifier)")
        
        if let httpResponse = response as? HTTPURLResponse {
            let trackStatus: TrackStatus = httpResponse.statusCode != 200 ? .waitingForUpload : .uploaded
            
            handleSendTrackResponse(with: dataTask, trackStatus: trackStatus)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let result = String(data: data, encoding: String.Encoding.utf8)
        pl("RESULT: \(String(describing: result))")
        
        let trackStatus: TrackStatus = result == "OK" ? .uploaded : .waitingForUpload
        
        handleSendTrackResponse(with: dataTask, trackStatus: trackStatus)
    }
    
    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    willCacheResponse proposedResponse: CachedURLResponse,
                    completionHandler: @escaping (CachedURLResponse?) -> Void) {
        pf()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            pl("task \(task.taskIdentifier) error -> \(error.localizedDescription)")
        } else {
            pl("task \(task.taskIdentifier) completed succesfully")
        }
    }
}



