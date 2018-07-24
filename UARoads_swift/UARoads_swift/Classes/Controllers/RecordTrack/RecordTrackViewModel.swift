//
//  RecordTrackViewModel.swift
//  UARoads_swift
//
//  Created by Roman on 7/25/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import CoreLocation

class RecordTrackViewModel {
    
    func gpsStatus(from location: CLLocation) -> GPS_Status {
        let status = location.horizontalAccuracy
        var gpsStatus: GPS_Status?
        if status < 0 {
            gpsStatus = .noSignal
        } else if status > 163 {
            gpsStatus = .low
        } else if status > 48 {
            gpsStatus = .middle
        } else {
            gpsStatus = .high
        }
        return gpsStatus!
    }
    
    func getUserStatistic(completion: @escaping (String?, Error?) -> () ) {
        let uid = Utilities.deviceUID()
        guard let email = SettingsManager.sharedInstance.email else {
            completion(nil, nil)
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let req = StatisticRequest { (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch response {
                case .success(r: let value):
                    guard let totalDistance = value["totalDistance"] as? Double else {
                        completion(nil,nil)
                        return
                    }
                    completion(String(totalDistance),nil)
                case .error(e: let error):
                    completion(nil,error)
            }
        }
        req.email = email
        req.uid = uid
        req.perform()
//        NetworkManager.sharedInstance.getUserStatistics(deviceUID: uid,
//                                                        email: email,
//                                                        completion: { (response, error) in
//                                                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                                                            pl(response)
//                                                            // TODO: parse response 
//                                                            // TODO: return observable, maybe
//                                                            completion("", error)
//                                                            
//        })
    }
    
    func attributedStringLastTrackDistance() -> NSAttributedString? {
        if let track: TrackModel = RealmHelper.objects(type: TrackModel.self)?.sorted(byKeyPath: "date", ascending: true).last {
            return attributedStringForTrackDistance(track.distance)
        }
        return attributedStringForTrackDistance(0.0)
    }
    
    func distanceStringInKilometers(_ distance: Double) -> String {
        let distanceStr = NSString(format:"%.2f", distance / 1000) as String
        return distanceStr
    }
    
    
    // MARK: Private funcs
    
    private func attributedStringForTrackDistance(_ distance: CGFloat) -> NSMutableAttributedString? {
        let distanceStr = distanceStringInKilometers(Double(distance))
        let kmStr = "km".localized
        let text = distanceStr + kmStr
        let rangeKm = text.nsRange(of: kmStr)
        let attributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 19),
                          NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        let attrStr = NSMutableAttributedString(string: text)
        attrStr.addAttributes(attributes, range: rangeKm)
        return attrStr
    }
    
}
