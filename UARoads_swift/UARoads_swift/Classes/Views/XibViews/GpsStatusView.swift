//
//  GpsStatusView.swift
//  UARoads_swift
//
//  Created by Roman Rybachenko on 7/13/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

class GpsStatusView: UIView {

    @IBOutlet var view: UIView!
    
    @IBOutlet weak var indicatorOneView: UIView!
    @IBOutlet weak var indicatorTwoView: UIView!
    @IBOutlet weak var indicatorThreeView: UIView!

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("GpsStatusView", owner: self, options: nil)
        self.addSubview(self.view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("GpsStatusView", owner: self, options: nil)
        self.addSubview(self.view)
    }
    
    
    func setGpsStatus(_ status: GPS_Status) {
        switch status {
        case .noSignal:
            indicatorOneView.backgroundColor = UIColor.darkGray
            indicatorTwoView.backgroundColor = UIColor.darkGray
            indicatorThreeView.backgroundColor = UIColor.darkGray
        case .low:
            indicatorOneView.backgroundColor = UIColor.redIndicator
            indicatorTwoView.backgroundColor = UIColor.darkGray
            indicatorThreeView.backgroundColor = UIColor.darkGray
        case .middle:
            indicatorOneView.backgroundColor = UIColor.greenIndicator
            indicatorTwoView.backgroundColor = UIColor.greenIndicator
            indicatorThreeView.backgroundColor = UIColor.darkGray
        case .high:
            indicatorOneView.backgroundColor = UIColor.greenIndicator
            indicatorTwoView.backgroundColor = UIColor.greenIndicator
            indicatorThreeView.backgroundColor = UIColor.greenIndicator
        }
    }
}
