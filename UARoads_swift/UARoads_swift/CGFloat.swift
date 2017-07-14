//
//  CGFloat.swift
//  UARoads_swift
//
//  Created by Roman Rybachenko on 7/14/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation

extension CGFloat {
    func degreesToRadians() -> CGFloat {
        return self * .pi / 180
    }
    
    func radiansToDegrees() -> CGFloat {
        return self * 180 / .pi
    }
}
