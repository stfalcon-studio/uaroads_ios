//
//  MutableData.swift
//
//  Created by Roman Rybachenko on 3/22/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation

public extension NSMutableData {
    public func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
