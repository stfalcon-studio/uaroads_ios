//
//  UARoadsSDK.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import Alamofire

final class UARoadsSDK {
    private init() {}
    static let sharedInstance = UARoadsSDK()
    
    //============
    static let baseURL = "http://api.uaroads.com"
    
    func send(track: TrackModel, handler: @escaping SuccessHandler) {
        track.statusEnum = TrackStatus.uploading
        
        let data = fullTrackData(track: track)
        let base64DataString = data?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let params: [AnyHashable:Any] = [
            "uid":self.getUUID(),
            "comment":track.title,
            "routeId":track.trackID,
            "data":base64DataString ?? "",
            "app_ver":version as! String,
            "auto_record":track.autoRecord ? "1" : "0",
            "date":track.date.timeIntervalSince1970
        ]
        
//        Alamofire.request(UARoadsSDK.baseURL + "/add", method: HTTPMethod.post, parameters: params, encoding: URLEncoding(), headers: nil).responseJSON(queue: nil, options: JSONSerialization.ReadingOptions.allowFragments) { response in
//            switch response.result {
//            case .success(let obj):
//                print("JSON: \(obj)")
//                
//                //                                    let json = JSON(obj)
//                
//                handler(true)
//                
//            case .failure(let error):
//                print("ERROR: \(error.localizedDescription)")
//                handler(false)
//            }
//        }
    }
    
    private func fullTrackData(track: TrackModel) -> Data? {
        var data: Data?
        var pitsDataList = [String]()
//        let pitsArray = track.pits.sorted(byKeyPath: "time", ascending: true)
//        for item in pitsArray {
//            pitsDataList.append(pitDataString(pit: item))
//        }
        let pitsDataString = pitsDataList.joined(separator: "#")
        data = pitsDataString.data(using: String.Encoding.utf8)
        
        if let data = data {
            return gzippedData(data)
        } else {
            return nil
        }
    }
    
    private func gzippedData(_ data: Data) -> Data {
        return (data as NSData).gzippedData(withCompressionLevel: -1.0)
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








