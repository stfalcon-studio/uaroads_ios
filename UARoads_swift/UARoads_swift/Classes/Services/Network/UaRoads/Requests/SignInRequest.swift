//
//  SignInRequest.swift
//  DOITTest
//
//  Created by Max Vasilevsky on 20.09.17.
//  Copyright © 2017 Max Vasilevsky. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class SignInRequest: BaseRequest {

    var email = ""
    
    override func apiPath() -> String {
        return "/register-device"
    }
    
    override func method() -> HTTPMethod {
        return .post
    }
    
    override func parameters() -> [String : Any] {
        let deviceName = "\(UIDevice.current.model) - \(UIDevice.current.name)"
        let osVersion = UIDevice.current.systemVersion
        let uid = UIDevice.current.identifierForVendor!.uuidString + "1"
        return  ["os":"ios",
                 "device_name":deviceName,
                 "os_version":osVersion,
                 "email":email,
                 "uid":uid]
    }
    
//    override func encoding() -> ParameterEncoding {
//        return URLEncoding.default
//    }
}
