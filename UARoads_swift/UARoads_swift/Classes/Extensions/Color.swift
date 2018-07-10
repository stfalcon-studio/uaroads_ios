//
//  Color.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

extension UIColor {
    class var colorPrimary: UIColor {
        return UIColor(red: 26 / 255.0, green: 135 / 255.0, blue: 247 / 255.0, alpha: 1.0)
    }
    
    class var colorPrimaryDark: UIColor {
        return UIColor(red: 12 / 255.0, green: 86 / 255.0, blue: 194 / 255.0, alpha: 1.0)
    }
    
    class var colorAccent: UIColor {
        return UIColor(red: 252 / 255.0, green: 91 / 255.0, blue: 34 / 255.0, alpha: 1.0)
    }
    
    class var greenIndicator: UIColor {
        return UIColor.rgba(red: 50, green: 156, blue: 50, alpha: 1.0)
    }
    
    class var redIndicator: UIColor {
        return UIColor.rgba(red: 218, green: 0, blue: 0, alpha: 1.0)
    }
    
    class var motionLineColor: UIColor {
        return UIColor.rgba(red: 189, green: 59, blue: 0, alpha: 1.0)
    }
    
    class func rgba(red: Float, green: Float, blue: Float, alpha: Float) -> UIColor {
        return UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
    }
}
