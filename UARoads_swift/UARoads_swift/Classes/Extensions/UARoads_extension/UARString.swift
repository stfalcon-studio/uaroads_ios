//
//  String.swift
//
//  Created by Roman Rybachenko on 4/3/17.
//  Copyright © 2017 UARoads. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func range(of string: String) -> NSRange {
        let nsStr = self as NSString
        let range = nsStr.range(of: string)
        return range
    }
    
    func range(of string: String, from range: NSRange) -> NSRange {
        let nsStr = self as NSString
        let options = String.CompareOptions.literal
        return nsStr.range(of: string, options: options, range: range)
    }
    
    
}

