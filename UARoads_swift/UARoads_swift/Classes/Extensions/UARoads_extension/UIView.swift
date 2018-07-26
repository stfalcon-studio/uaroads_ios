//
//  UIImage.swift
//
//  Created by Victor Amelin on 2/16/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    public func gradientSublayer(colorA: UIColor = UIColor.red, colorB: UIColor = UIColor.green) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [colorA, colorB].map{$0.cgColor}
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    public func addDashedLine(startPoint: CGPoint, endPoint: CGPoint, color: UIColor, lineWidth: CGFloat, step: Int) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        line.path = linePath.cgPath
        line.strokeColor = color.cgColor
        line.lineWidth = lineWidth
        line.lineJoin = kCALineJoinRound
        line.lineDashPattern = NSArray(objects: NSNumber(value: step), NSNumber(value: step)) as? [NSNumber]
        self.layer.addSublayer(line)
    }
    
    public func snapshotImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }
    
    public func snapshotImageView() -> UIImageView? {
        if let snapshotImage = snapshotImage() {
            return UIImageView(image: snapshotImage)
        } else {
            return nil
        }
    }
}
