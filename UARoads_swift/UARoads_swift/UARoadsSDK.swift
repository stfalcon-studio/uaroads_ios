//
//  UARoadsSDK.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation

final class UARoadsSDK <TPit: PitProtocol> {
    private init() {}
    
    class func encodePoints(_ points: [TPit]) -> String? {
        var data: Data?
        var pitsDataList = [String]()
        
        for item in points {
            pitsDataList.append(pitDataString(pit: item))
        }
        
        let pitsDataString = pitsDataList.joined(separator: "#")
        data = pitsDataString.data(using: String.Encoding.utf8)!
        
        if let data = data {
            return gzippedData(data)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        } else {
            return nil
        }
    }
    
    private class func gzippedData(_ data: Data) -> Data? {
        return (data as NSData).gzippedData(withCompressionLevel: -1.0) ?? nil
    }
    
    private class func pitDataString(pit: TPit) -> String {
        let pitValueStr = (pit.value == 0.0) ? "0" : "\(NSString(format: "%.5f", pit.value))"
        let result = "\(pit.time);\(pitValueStr);\(pit.latitude);\(pit.longitude);\(pit.tag)"
        return result;
    }
}








