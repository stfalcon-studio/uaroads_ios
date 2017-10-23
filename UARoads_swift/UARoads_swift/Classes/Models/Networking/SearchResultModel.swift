//
//  SearchResultModel.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import CoreLocation

struct SearchResultModel {
    let locationCoordianate: CLLocationCoordinate2D?
    let locationName: String?
    let locationDescription: String?
}

//extension SearchResultModel: Equatable {
//    static func ==(lhs: SearchResultModel, rhs: SearchResultModel) -> Bool {
//        let isEquelCoordinate = (lhs.locationCoordianate?.latitude == rhs.locationCoordianate?.latitude && lhs.locationCoordianate?.longitude == rhs.locationCoordianate?.longitude)
//        let isEquelName = lhs.locationName == rhs.locationName
//        return isEquelName && isEquelCoordinate
//    }
//}

