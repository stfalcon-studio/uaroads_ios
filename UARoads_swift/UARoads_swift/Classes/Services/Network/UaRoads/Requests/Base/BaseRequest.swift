//
//  BaseRequest.swift
//  DOITTest
//
//  Created by Max Vasilevsky on 20.09.17.
//  Copyright © 2017 Max Vasilevsky. All rights reserved.
//

import Foundation
import Alamofire

class BaseRequest: NSObject, BaseRequestProtocol {
    
    
    var parametersWithSessionKey: NSMutableDictionary
    var completion  : (ResponseType)->()
    var progress    : (Float)->()
    
    init(completionClosure: @escaping (_ response:ResponseType)->()){
        completion = completionClosure
        progress = { progress in}
        parametersWithSessionKey = NSMutableDictionary()
    }
    
    func method() -> HTTPMethod{
        return .get
    }
    
    func baseURL() -> ApiPath {
        return .basePath
    }
    
    func data() -> Data? {
        return nil
    }
    
    func type() -> RequestType {
        return .defaultRequest
    }
    
    func apiPath()->String {
        return ""
    }
    
    func parameters()-> [String:Any]{
        return [:]
    }
    
    func encoding() -> ParameterEncoding {
        return URLEncoding.default
    }
    
    func formData() -> [String:Data] {
        return [:]
    }
    
    func imageData() -> [String : Data] {
        return [:]
    }
    
    func requestCompleted(_ response: ResponseType) {
        self.completion(response)
    }
    
    func requestProgress(_ progress: Float){
        self.progress(progress)
    }
    
    func performRequest() -> DataRequest {
        return APIUARoads.service.performJSONRequest(self)
    }
    
    func perform() {
        let _ = self.performRequest()
    }
    
    
}
