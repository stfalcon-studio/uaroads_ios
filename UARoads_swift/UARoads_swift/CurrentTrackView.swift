//
//  CurrentTrackView.swift
//  UARoads_swift
//
//  Created by Roman Rybachenko on 7/13/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

class CurrentTrackView: UIView {
    
    // MARK: Outlets
    @IBOutlet var view: UIView!
    
    @IBOutlet weak var currentTrackTitleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var gpsTitleLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        Bundle.main.loadNibNamed("CurrentTrackView", owner: self, options: nil)
        self.addSubview(self.view)
    }
    
    func setDistance(_ distance: Double) {
        distanceLabel.text = NSString(format: "%.2f km", distance/1000.0) as String
    }

}
