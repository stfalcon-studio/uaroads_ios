//
//  RecordedCell.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/10/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

class RecordedCell: BaseCell {
    let dateLbl = UILabel()
    let stateLbl = UILabel()
    let distLbl = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //setup constraints
        addSubview(dateLbl)
        addSubview(stateLbl)
        addSubview(distLbl)
        
        dateLbl.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8.0)
            make.left.equalToSuperview().offset(15.0)
        }
        
        stateLbl.snp.makeConstraints { (make) in
            make.left.equalTo(dateLbl)
            make.top.equalTo(dateLbl.snp.bottom).offset(5.0)
            make.bottom.equalToSuperview().offset(-8.0)
        }
        
        distLbl.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15.0)
            make.centerY.equalToSuperview()
        }
        
        //setup interface
        separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0)
        
        stateLbl.textColor = UIColor.lightGray
        stateLbl.font = UIFont.systemFont(ofSize: 12.0)
        
        distLbl.textColor = UIColor.colorPrimaryDark
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
