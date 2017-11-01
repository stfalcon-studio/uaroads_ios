//
//  BaseRequestProtocol.swift
//  DOITTest
//
//  Created by Max Vasilevsky on 20.09.17.
//  Copyright © 2017 Max Vasilevsky. All rights reserved.
//

import Foundation
import Alamofire

protocol BaseRequestProtocol {
    func data()->Data?
    func method()->HTTPMethod
    func apiPath()->String
    func parameters()->[String:Any]
    func formData()->[String:Data]
    func imageData()->[String:Data]
    func encoding()->ParameterEncoding
    func baseURL() -> ApiPath
    func type() -> RequestType
    
    
    func requestCompleted(_ response:ResponseType)
    func requestProgress(_ progress: Float)
}

extension BaseRequestProtocol {
    var isUpload:Bool {
        return !self.formData().isEmpty || !self.imageData().isEmpty
    }
}

enum ResponseType{
    case success(r: AnyObject)
    case error(e: Error)
}

enum RequestType {
    case defaultRequest
    case searchLocation
}
