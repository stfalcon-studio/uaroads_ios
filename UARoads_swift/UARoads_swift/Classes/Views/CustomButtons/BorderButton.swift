//
//  BorderButton.swift
//  Triplook
//
//  Created by Roman Rybachenko on 5/11/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit


@IBDesignable
class BorderButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var numberOfLinesTitle: Int = 1 {
        didSet {
            self.titleLabel?.lineBreakMode = .byWordWrapping
            self.titleLabel?.numberOfLines = numberOfLinesTitle
            self.titleLabel?.textAlignment = .center
        }
    }
    
    

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0
        layer.borderWidth = borderWidth
    }

}
