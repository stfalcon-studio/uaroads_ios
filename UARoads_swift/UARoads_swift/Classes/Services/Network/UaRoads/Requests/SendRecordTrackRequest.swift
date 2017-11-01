//
//  SignUpRequest.swift
//  DOITTest
//
//  Created by Max Vasilevsky on 20.09.17.
//  Copyright © 2017 Max Vasilevsky. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class SendRecordTrackRequest: BaseRequest {
    
    var params = [String : Any]()
//    var trackData:Data!
    
    override func apiPath() -> String {
        return "/add"
    }
    
    override func method() -> HTTPMethod {
        return .post
    }
    
    override func baseURL() -> ApiPath {
        return .apiPath
    }

    override func parameters() -> [String : Any] {
        return params
//        params["data"] = trackData.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
//        return params
//        ["uid": UIDevice.current.identifierForVendor!.uuidString,
//                "comment":track.title,
//                "routeId":track.trackID,
//                "app_ver":version,
//                "auto_record" : track.autoRecord]
    }
    
//    override func formData() -> [String : Data] {
//        return ["data":trackData]
//    }
    
    override func perform() {
        APIUARoads.service.performStringRequest(self)
    }

}
