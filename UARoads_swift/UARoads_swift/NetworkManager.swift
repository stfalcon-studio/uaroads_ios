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
    
    func searchResults(location: String, handler: @escaping SearchLocationHandler) {
        let coord = LocationManager.sharedInstance.manager.location?.coordinate ?? CLLocationCoordinate2DMake(0.0, 0.0)
        let params = [
            "lang":"uk_UA",
            "format":"json",
            "ll":"\(coord.latitude), \(coord.longitude)",
            "geocode":"Україна, \(location)"
        ]
        let url = URL(string: "https://geocode-maps.yandex.ru/1.x"+buildQueryString(fromDictionary: params))
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
    
    //MARK: Helpers
    private func buildQueryString(fromDictionary parameters: [String:String]) -> String {
        var urlVars:[String] = []
        for (k, value) in parameters {
            if let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                urlVars.append(k + "=" + encodedValue)
            }
        }
        return urlVars.isEmpty ? "" : "?" + urlVars.joined(separator: "&")
    }
}






















