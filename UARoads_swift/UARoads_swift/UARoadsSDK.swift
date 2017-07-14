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
        
        var allPitsString: String = ""
        for item in points {
            allPitsString.append(pitDataString(pit: item))
        }
        data = allPitsString.data(using: String.Encoding.utf8)
        if data != nil {
            guard let zipData = gzippedData(data!) else { return nil }
            let base64Str = zipData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            return base64Str
        } else {
            return nil
        }
    }
    
    private class func gzippedData(_ data: Data) -> Data? {
        return (data as NSData).gzippedData(withCompressionLevel: -1.0) ?? nil
    }
    
    private class func pitDataString(pit: TPit) -> String {
        let pitValueStr = (pit.value == 0.0) ? "0" : "\(NSString(format: "%.5f", pit.value))"
        let result = "\(pit.time);\(pitValueStr);\(pit.latitude);\(pit.longitude);\(pit.tag);\(pit.horizontalAccuracy);\(pit.speed)#"
        return result;
    }
}








