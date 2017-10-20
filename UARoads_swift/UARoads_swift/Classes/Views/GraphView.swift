//
//  GraphView.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/11/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

class GraphView: UIView {
    fileprivate var valuesList: [CGFloat]!
    fileprivate var filteredValuesList: [CGFloat]!
    fileprivate var maxValue: CGFloat!
    
    init() {
        super.init(frame: CGRect.zero)
        maxValue = 2.5
        valuesList = [CGFloat]()
        filteredValuesList = [CGFloat]()
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        let middleY = self.frame.size.height - 10.0
        let zoomY = (self.frame.size.height - 20) / maxValue
        
        let context = UIGraphicsGetCurrentContext()
        
        if valuesList.count > 0 && maxValue > 0.0 {
            var startPos: Int = Int(self.frame.size.width)
            let zoomX = 5
            
            context?.setLineWidth(2.0)
            
            if valuesList.count * zoomX < Int(self.frame.size.width) {
                startPos = valuesList.count * zoomX;
            }
            
            var i = 0
            while i < valuesList.count && i*zoomX < Int(self.frame.size.width) {
                i += 1
                if i > 0 && i < valuesList.count - 1 {
                    let valueX1: CGFloat = CGFloat(startPos - i*zoomX)
                    let valueY1: CGFloat = middleY - valuesList[i] * zoomY
                    let valueX2: CGFloat = CGFloat(startPos - (i+1)*zoomX)
                    let valueY2: CGFloat = middleY - valuesList[i+1] * zoomY
                    
                    context?.setStrokeColor(UIColor.motionLineColor.cgColor)
                    context?.move(to: CGPoint(x: valueX1, y: valueY1))
                    context?.addLine(to: CGPoint(x: valueX2, y: valueY2))
                }
            }
            context?.strokePath()
            
//            i = 0
//            while i < valuesList.count && i*zoomX < Int(self.frame.size.width) {
//                i += 1
//                if i > 0 && i < valuesList.count - 1 && i < filteredValuesList.count - 1 {
//                    let valueX1: CGFloat = CGFloat(startPos - i*zoomX)
//                    let valueY1: CGFloat = middleY - filteredValuesList[i] * zoomY
//                    let valueX2: CGFloat = CGFloat(startPos - (i+1)*zoomX)
//                    let valueY2: CGFloat = middleY - filteredValuesList[i+1] * zoomY
//
//                    context?.setStrokeColor(UIColor.colorPrimary.cgColor)
//                    context?.move(to: CGPoint(x: valueX1, y: valueY1))
//                    context?.addLine(to: CGPoint(x: valueX2, y: valueY2))
//                }
//            }
//            context?.strokePath()
        }
    }
}










