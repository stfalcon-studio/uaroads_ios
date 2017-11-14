//
//  YandexManager.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation

class NetworkManager {
    private init() {}
    static let sharedInstance = NetworkManager()
    
//    func tryToSendData(params: [String:AnyObject], handler: @escaping (_ success: Bool) -> ()) {
//        pf()
//        pl(params)
//        var request = URLRequest(url: URL(string: "http://api.uaroads.com/add")!)
//        request.httpBody = NSKeyedArchiver.archivedData(withRootObject: params)
//        request.httpMethod = "POST"
//
//        URLSession.shared.dataTask(with: request) {[weak self] (data, response, error) in
//            let successRequest: Bool = self?.parseSendTrackResponse(data, error: error) ?? false
//            DispatchQueue.main.async {
//                handler(successRequest)
//            }
//        }.resume()
//    }
    
//    func authorizeDevice(email: String, handler: @escaping (_ success: Bool) -> ()) {
//        let deviceName = "\(UIDevice.current.model) - \(UIDevice.current.name)"
//        let osVersion = UIDevice.current.systemVersion
//        let uid = Utilities.deviceUID()
//        let params = [
//            "os":"ios",
//            "device_name":deviceName,
//            "os_version":osVersion,
//            "email":email,
//            "uid":uid
//        ]
//
//        var request = URLRequest(url: URL(string: "http://uaroads.com/register-device")!)
//        request.httpBody = NSKeyedArchiver.archivedData(withRootObject: params)
//        request.httpMethod = "POST"
//
//
//
//        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
//            let isAuthorized: Bool = self?.parseAuthorizeDeviceResponse(data, error: error) ?? false
//            DispatchQueue.main.async {
//                handler(isAuthorized)
//            }
//        }.resume()
//    }
    
//    func getUserStatistics(deviceUID: String,
//                           email: String,
//                           completion: @escaping (_ respose: [String : AnyObject]?, _ error: Error?) -> () ) {
//        let urlStr = "http://uaroads.com/statistic?uid=\(deviceUID)&user=\(email)"
//        guard let url = URL(string: urlStr) else { return }
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "GET"
//        URLSession.shared.dataTask(with: urlRequest,
//                                   completionHandler: { (data, urlResponse, error) in
//                                    var responseDict: [String : AnyObject]?
//                                    if let respData = data {
//                                        responseDict = try! JSONSerialization.jsonObject(with: respData, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
//                                    }
//                                    DispatchQueue.main.async {
//                                        completion(responseDict, error)
//                                    }
//
//                                    
//        }).resume()
//    }
    
    func checkRouteAvailability(coord1: CLLocationCoordinate2D,
                                coord2: CLLocationCoordinate2D,
                                handler: @escaping (_ status: Int) -> ()) {
        
        let req = RouteCheckRequest { (result) in
            switch result {
            case .success(let value):
                let json = JSON(value)
                guard  let status = json["status"].int else {
                    handler(404)
                    return
                }
                handler(status)
            case .error(_) :
                handler(404)
            }
        }
        req.coord1 = coord1
        req.coord2 = coord2
        req.perform()
    }
    
    func searchResults(location: String,
                       coord: CLLocationCoordinate2D,
                       handler: @escaping SearchLocationHandler) {
        let req = SearchGeoRequest {[weak self] (result) in
            switch result {
            case .success(let value):
                let json = JSON(value)
                let result = self?.parseSearchResultsResponse(json) ?? [SearchResultModel]()
                handler(result)
            case .error(let error) :
                print(error)
            }
        }
        req.locationName = location
        req.coordinate = coord
        req.perform()
        return
//        let params = [
//            "lang":"uk_UA",
//            "format":"json",
//            "ll":"\(coord.latitude), \(coord.longitude)",
//            "geocode":"Україна, \(location)"
//        ]
//        let url = URL(string: "http://geo.uaroads.com/1.x/" + String.buildQueryString(fromDictionary: params))
//        let request = URLRequest(url: url!)
//
//        URLSession.shared.dataTask(with: request) { [weak self] (data, _, error) in
//            DispatchQueue.main.async {
//                if let data = data, error == nil {
////                    let result = self?.parseSearchResultsResponse(data) ?? [SearchResultModel]()
////                    handler(result)
//                }
//            }
//        }.resume()
    }
    
    
    // MARK: Private funcs
    
    private func parseSearchResultsResponse(_ responseData: JSON) -> [SearchResultModel] {
        var result = [SearchResultModel]()
        let json = responseData
        
        guard let featureMember = json["response"].dictionary?["GeoObjectCollection"]?.dictionary?["featureMember"]?.array else { return result }
        
        for item in featureMember {
            let geoObject = item["GeoObject"].dictionary
            let description = geoObject?["description"]?.string
            let name = geoObject?["name"]?.string
            let pos = geoObject?["Point"]?.dictionary?["pos"]?.string
            let coordArr = pos?.components(separatedBy: " ")
            let locationCoord = CLLocationCoordinate2DMake(CLLocationDegrees(Float(coordArr![1])!),
                                                           CLLocationDegrees(Float(coordArr![0])!))
            let model = SearchResultModel(locationCoordianate: locationCoord, locationName: name, locationDescription: description)
            
            result.append(model)
        }
        return result
    }
    
//    private func parseSendTrackResponse(_ responseData: Data?,  error: Error?) -> Bool {
//        if let data = responseData {
//            let result = String(data: data, encoding: String.Encoding.utf8)
//            pl("RESULT: \(String(describing: result))")
//
//            if result == "OK" {
//                return true
//            } else {
//                return false
//            }
//        } else {
//            pl("send track error -> \n\(String(describing: error))")
//            return false
//        }
//    }
    
//    private func parseAuthorizeDeviceResponse(_ responseData: Data?, error: Error?) -> Bool {
//        guard let data = responseData else {
//            pl("authorize response error: \(String(describing: error))")
//            return false
//        }
//        guard let responseDict = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject] else {
//            return false
//        }
//
//        if let status: String = responseDict["status"] as? String, status == "success" {
//            return true
//        } else {
//            return false
//        }
//    }
    
    
}



