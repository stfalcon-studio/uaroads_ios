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
    
    private var sendingInProcess = false
    
    func sendPits(params: [String:String], handler: @escaping SuccessHandler) {
        AnalyticManager.sharedInstance.reportEvent(category: "System", action: "SendDataActivity Start")
        
        let pred = NSPredicate(format: "(status == 2) OR (status == 3)")
        let result = RecordService.sharedInstance.dbManager.objects(type: TrackModel.self)?.filter(pred)
        
        if !sendingInProcess {
            if let result = result, result.count > 0 {
                sendingInProcess = true
                
                let track = result.first
                RecordService.sharedInstance.dbManager.update {
                    track?.status = TrackStatus.uploading.rawValue
                }
                self.tryToSend(params: params, handler: { val in
                    self.sendingInProcess = false
                    
                    if result.count > 1 && val {
                        self.sendPits(params: params, handler: handler) //recursion
                    } else {
                        (UIApplication.shared.delegate as? AppDelegate)?.completeBackgroundTrackSending(val)
                    }
                    
                    RecordService.sharedInstance.dbManager.update {
                        if val == true {
                            track?.status = TrackStatus.uploaded.rawValue
                        } else {
                            track?.status = TrackStatus.waitingForUpload.rawValue
                        }
                    }
                })
            }
        }
        if !sendingInProcess {
            (UIApplication.shared.delegate as? AppDelegate)?.completeBackgroundTrackSending(false)
        }
        AnalyticManager.sharedInstance.reportEvent(category: "System", action: "sendDataActivity End")
    }
    
    private func tryToSend(params: [String:String], handler: @escaping (_ success: Bool) -> ()) {
        var request = URLRequest(url: URL(string: "http://uaroads.com/add" + String.buildQueryString(fromDictionary: params))!)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { (data, response, _) in
            DispatchQueue.main.async {
                if let data = data {
                    let result = String(data: data, encoding: String.Encoding.utf8)
                    
                    print("RESULT: \(String(describing: result))")
                    
                    if result == "OK" {
                        handler(true)
                    } else {
                        handler(false)
                    }
                } else {
                    handler(false)
                }
            }
        }.resume()
    }
    
    func authorizeDevice(email: String, handler: @escaping (_ success: Bool) -> ()) {
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
        
        print(params)
        
        var request = URLRequest(url: URL(string: "http://uaroads.com/add/register-device")!)
        request.httpBody = NSKeyedArchiver.archivedData(withRootObject: params)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request) { (data, _, _) in
            DispatchQueue.main.async {
                if let data = data {
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
            }.resume()
    }
    
    func checkRouteAvailability(coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D, handler: @escaping (_ status: Int) -> ()) {
        var request = URLRequest(url: URL(string: "http://route.uaroads.com/viaroute?output=json&instructions=false&geometry=false&alt=false&loc=\(coord1.latitude),\(coord1.longitude)&loc=\(coord2.latitude),\(coord2.longitude)")!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (_, response, _) in
            DispatchQueue.main.async {
                if let status = (response as? HTTPURLResponse)?.statusCode {
                    handler(status)
                } else {
                    handler(404)
                }
            }
        }.resume()
    }
    
    func searchResults(location: String, coord: CLLocationCoordinate2D, handler: @escaping SearchLocationHandler) {
        let params = [
            "lang":"uk_UA",
            "format":"json",
            "ll":"\(coord.latitude), \(coord.longitude)",
            "geocode":"Україна, \(location)"
        ]
        let url = URL(string: "https://geocode-maps.yandex.ru/1.x" + String.buildQueryString(fromDictionary: params))
        let request = URLRequest(url: url!)
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            DispatchQueue.main.async {
                if let data = data, error == nil {
                    let json = JSON(data: data)
                    let featureMember = json["response"].dictionary?["GeoObjectCollection"]?.dictionary?["featureMember"]?.array
                    
                    var result = [SearchResultModel]()
                    if let featureMember = featureMember {
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
                    }
                    handler(result)
                }
            }
        }.resume()
    }
}






















