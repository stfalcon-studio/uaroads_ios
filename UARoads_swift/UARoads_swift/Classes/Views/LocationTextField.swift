//
//  LocationTextField.swift
//  UARoads_swift
//
//  Created by Andrew Yaniv on 7/12/18.
//  Copyright © 2018 Victor Amelin. All rights reserved.
//

import UIKit

class LocationTextField: UITextField {

    private let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

}
