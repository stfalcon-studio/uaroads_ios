//
//  UARoadsSDK.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import Alamofire
import CoreLocation
import UHBConnectivityManager

public final class UARoadsSDK {
    private init() {}
    public static let sharedInstance = UARoadsSDK()
    
    //============
    private static let baseURL = "http://uaroads.com"
    private var sendingInProcess = false
    
    public func checkRouteAvailability(coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D, handler: @escaping (_ status: Int) -> ()) {
        Alamofire.request("http://route.uaroads.com/viaroute?output=json&instructions=false&geometry=false&alt=false&loc=\(coord1.latitude),\(coord1.longitude)&loc=\(coord2.latitude),\(coord2.longitude)", method: .get, parameters: nil, encoding: JSONEncoding(), headers: nil).responseJSON { response in
            if let code = response.response?.statusCode {
                handler(code)
            } else {
                handler(404)
            }
        }
    }
    
    public func authorizeDevice(email: String, handler: @escaping (_ success: Bool) -> ()) {
        let deviceName = "\(UIDevice.current.model) - \(UIDevice.current.name)"
        let osVersion = UIDevice.current.systemVersion
        let uid = UIDevice.current.identifierForVendor?.uuidString
        let params = [
            "os":"ios",
            "device_name":deviceName,
            "os_version":osVersion,
            "email":email,
            "uid":uid!
        ]
        
        print("\(UARoadsSDK.baseURL)/register-device")
        print(params)
        
        Alamofire.request("\(UARoadsSDK.baseURL)/register-device", method: .post, parameters: params, encoding: JSONEncoding(), headers: nil).responseJSON { response in
            if let data = response.data {
                let result = String(data: data, encoding: String.Encoding.utf8)
                if result == "OK" {
                    handler(true)
                } else {
                    handler(false)
                }
            } else {
                handler(false)
            }
        }
    }
    
    public func sendDataActivity() {
        AnalyticManager.sharedInstance.reportEvent(category: "System", action: "SendDataActivity Start")
        
        let pred = NSPredicate(format: "(status == 2) OR (status == 3)")
        let result = RealmManager.sharedInstance.objects(type: TrackModel.self)?.filter(pred)
        
        if !sendingInProcess {
            if let result = result, result.count > 0 {
                if UHBConnectivityManager.shared().isConnected() == true {
                    sendingInProcess = true
                    
                    let track = result.first
                    RealmManager.sharedInstance.update {
                        track?.status = TrackStatus.uploading.rawValue
                    }
                    UARoadsSDK.sharedInstance.tryToSend(track: track!, handler: { [weak self] val in
                        self?.sendingInProcess = false
                        
                        if result.count > 1 && val {
                            self?.sendDataActivity()
                        } else {
                            (UIApplication.shared.delegate as? AppDelegate)?.completeBackgroundTrackSending(val)
                        }
                        
                        RealmManager.sharedInstance.update {
                            if val == true {
                                track?.status = TrackStatus.uploaded.rawValue
                            } else {
                                track?.status = TrackStatus.waitingForUpload.rawValue
                            }
                        }
                    })
                }
            }
        }
        if !sendingInProcess {
            (UIApplication.shared.delegate as? AppDelegate)?.completeBackgroundTrackSending(false)
        }
        AnalyticManager.sharedInstance.reportEvent(category: "System", action: "sendDataActivity End")
    }
    
    private func tryToSend(track: TrackModel, handler: @escaping (_ success: Bool) -> ()) {
        AnalyticManager.sharedInstance.reportEvent(category: "System", action: "sendDataActivity End")
        
        let data = fullTrackData(track: track)
        let base64DataString = data?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let params = [
            "uid":self.getUUID(),
            "comment":track.title,
            "routeId":track.trackID,
            "data":base64DataString ?? "",
            "app_ver":version as! String,
            "auto_record":track.autoRecord ? "1" : "0",
            "date":track.date.timeIntervalSince1970
        ] as [String : Any]
        
        print("\(UARoadsSDK.baseURL)/add")
        print(params)
        
        Alamofire.request("\(UARoadsSDK.baseURL)/add", method: .post, parameters: params, encoding: JSONEncoding(), headers: nil).responseJSON { response in
            if let data = response.data {
                let result = String(data: data, encoding: String.Encoding.utf8)
                if result == "OK" {
                    handler(true)
                } else {
                    handler(false)
                }
            } else {
                handler(false)
            }
            
            var code: NSNumber?
            if let number = response.response?.statusCode {
                code = NSNumber(integerLiteral: number)
            }
            
            AnalyticManager.sharedInstance.reportEvent(category: "System", action: "SendTrack Complete",
                                                       label: "code",
                                                       value: code)
        }
    }
    
    private func fullTrackData(track: TrackModel) -> Data? {
        var data: Data?
        var pitsDataList = [String]()

        let pitsArray = track.pits.sorted(byKeyPath: "time", ascending: true)
        print(pitsArray as Any)
        for item in pitsArray {
            pitsDataList.append(pitDataString(pit: item))
        }
        
        let pitsDataString = pitsDataList.joined(separator: "#")
        data = pitsDataString.data(using: String.Encoding.utf8)!
        
        if let data = data {
            return gzippedData(data)
        } else {
            return nil
        }
    }
    
    private func gzippedData(_ data: Data) -> Data? {
        return (data as NSData).gzippedData(withCompressionLevel: -1.0) ?? nil
    }
    
    private func pitDataString(pit: PitModel) -> String {
        let pitValueStr = pit.value == 0.0 ? "0" : "\(pit.value)"
        let result = "\(pit.time);\(pitValueStr);\(pit.latitude);\(pit.longitude);\(pit.tag)"
        return result;
    }
    
    private func getUUID() -> String {
        let uuid = NSUUID().uuidString
        return uuid
    }
}








