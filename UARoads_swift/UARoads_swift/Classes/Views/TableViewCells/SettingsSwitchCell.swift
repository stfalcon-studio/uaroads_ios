//
//  SettingsSwitchCell.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/13/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

class SettingsSwitchCell: BaseCell {
    let mainTitleLbl = UILabel()
    let switcher = UISwitch()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //setup constrants
        addSubview(mainTitleLbl)
        addSubview(switcher)
        
        mainTitleLbl.snp.makeConstraints { (make) in
            make.left.equalTo(15.0)
            make.centerY.equalTo(self.snp.centerY)
            make.right.equalTo(switcher.snp.left)
        }
        
        switcher.snp.makeConstraints { (make) in
            make.right.equalTo(-15.0).priority(1000)
            make.centerY.equalToSuperview()
        }
        
        //setup interface
        separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0)
        
        mainTitleLbl.font = UIFont.systemFont(ofSize: 14.0)
        mainTitleLbl.numberOfLines = 0
        switcher.onTintColor = UIColor.colorAccent
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}








