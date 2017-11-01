//
//  APIService.swift
//  APIService
//
//  Created by Max Vasilevsky on 20.09.17.
//  Copyright © 2017 Max Vasilevsky. All rights reserved.
//

import Foundation

import Foundation
import Alamofire
import SwiftyJSON

enum ApiPath:String {
    case basePath = "http://uaroads.com"
    case apiPath = "http://api.uaroads.com"
    case routePath = "http://route.uaroads.com"
    case geoPath = "http://geo.uaroads.com/1.x/"
}

final class APIUARoads {
    static let service = APIUARoads()
    
    func performJSONRequest(_ requestItem: BaseRequestProtocol) -> DataRequest {
        let req = request(requestItem.baseURL().rawValue + requestItem.apiPath(), method: requestItem.method(), parameters: requestItem.parameters(), encoding: requestItem.encoding(), headers:nil)
        req.responseJSON(options: .allowFragments, completionHandler: { (response) in
            switch response.result {
            case .success(let value):
                requestItem.requestCompleted(.success(r: value as AnyObject))
            case .failure(let error):
                requestItem.requestCompleted(.error(e: error))
            }
        })
        return req
    }
    
    func performStringRequest(_ requestItem: BaseRequestProtocol) {
        let req = request(requestItem.baseURL().rawValue + requestItem.apiPath(), method: requestItem.method(), parameters: requestItem.parameters(), encoding: requestItem.encoding(), headers:nil)
        req.responseString { (response) in
            switch response.result {
            case .success(let value):
                requestItem.requestCompleted(.success(r: value as AnyObject))
            case .failure(let error):
                requestItem.requestCompleted(.error(e: error))
            }
        }
    }
    
    
//    func performRequest(_ requestItem: BaseRequestProtocol) -> DataRequest {
//        return performJSONRequest(requestItem)
//        if requestItem.isUpload {
////            performUploadRequest(requestItem)
//        } else {
//            return performJSONRequest(requestItem)
//        }
//    }
    
    func performUploadRequest(_ requestItem: BaseRequestProtocol) {
        upload(multipartFormData: { (multipartFormData) in
//            for (key, value) in requestItem.formData(){
//                multipartFormData.append(value, withName: key)
//            }
            for (key, value) in requestItem.parameters() as! [String:String] {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: requestItem.baseURL().rawValue+requestItem.apiPath(),
           method:requestItem.method(),
           headers:nil,
           encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .failure(let error):
                        requestItem.requestCompleted(.error(e: error))
                    case .success(let value):
                        requestItem.requestCompleted(.success(r: value as AnyObject))
                    }
                })
            case .failure(let encodingError):
                requestItem.requestCompleted(.error(e: encodingError))
            }
        })
    }

}

