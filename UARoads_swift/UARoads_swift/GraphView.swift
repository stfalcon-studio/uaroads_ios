//
//  GraphView.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/11/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

class GraphView: UIView {
    fileprivate var valuesList = [CGFloat]()
    fileprivate var filteredValuesList = [CGFloat]()
    fileprivate var maxValue: CGFloat = 2.5
    
    func addValue(_ value: CGFloat, isFiltered: Bool) {
        var val = value
        if val > maxValue {
            val = maxValue
        }
        valuesList.insert(val, at: 0)
        
        if isFiltered == true {
            filteredValuesList.insert(0.0, at: 0)
        } else {
            filteredValuesList.insert(val, at: 0)
        }
        setNeedsDisplay()
    }
    
    func clear() {
        valuesList.removeAll()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        var middleY = self.frame.size.height - 10.0
        var zoomY = (self.frame.size.height - 20) / maxValue
        
        let context = UIGraphicsGetCurrentContext()
        
        if valuesList.count > 0 && maxValue > 0.0 {
            var startPos: CGFloat = self.frame.size.width
            let zoomX: CGFloat = 5.0
            
            context?.setLineWidth(2.0)
            
            if CGFloat(valuesList.count) * zoomX < self.frame.size.width {
                startPos = CGFloat(valuesList.count) * zoomX;
            }
            
            for i in 0..<valuesList.count { //(int i = 0; i < valuesList.count && i*zoomX < self.frame.size.width; i++) {
                if i > 0 && i < valuesList.count - 1 {
                    let valueX1 = startPos - i*zoomX;
                    let valueY1 = middleY - [valuesList[i] floatValue] * zoomY;
                    let valueX2 = startPos - (i+1)*zoomX;
                    let valueY2 = middleY - [valuesList[i+1] floatValue] * zoomY;
                    
                    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
                    CGContextMoveToPoint(context, valueX1, valueY1);
                    CGContextAddLineToPoint(context, valueX2, valueY2);
                }
            
            }
            context?.strokePath()
        }
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        //
    }
}










