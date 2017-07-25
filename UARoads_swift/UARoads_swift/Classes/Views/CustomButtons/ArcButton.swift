//
//  ArcButton.swift
//  UARoads_swift
//
//  Created by Roman Rybachenko on 7/14/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit


class ArcButton: UIButton {

    @IBInspectable var arcCenter: CGPoint = CGPoint.zero
    @IBInspectable var radius: CGFloat = 0
    @IBInspectable var startAngle: CGFloat = 0
    @IBInspectable var endAngle: CGFloat = 0
    @IBInspectable var clockwise: Bool = true
    
    var path: UIBezierPath!
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        path = UIBezierPath(arcCenter: arcCenter,
                            radius: radius,
                            startAngle: startAngle.degreesToRadians(),
                            endAngle: endAngle.degreesToRadians(),
                            clockwise: clockwise)
        path.close()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let contains = path.contains(point)
        if contains == true {
            return self
        }
        return nil
    }

}
