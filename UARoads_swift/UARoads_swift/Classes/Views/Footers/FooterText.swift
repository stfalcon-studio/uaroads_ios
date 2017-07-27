//
//  FooterText.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/13/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

class FooterText: UIView {
    let versionLbl = UILabel()
    let uidLbl = UILabel()
    
    init() {
        super.init(frame: CGRect.zero)
        
        //setup constraints
        addSubview(versionLbl)
        addSubview(uidLbl)
        
        versionLbl.snp.makeConstraints { (make) in
            make.left.equalTo(15.0)
            make.right.equalTo(-15.0)
            make.top.equalToSuperview().offset(20.0)
        }
        
        uidLbl.snp.makeConstraints { (make) in
            make.left.equalTo(versionLbl)
            make.right.equalTo(versionLbl)
            make.top.equalTo(versionLbl.snp.bottom).offset(10.0)
        }
        
        //setup interface
        versionLbl.font = UIFont.systemFont(ofSize: 12.0)
        versionLbl.textColor = UIColor.gray
        versionLbl.numberOfLines = 0
        
        uidLbl.font = UIFont.systemFont(ofSize: 12.0)
        uidLbl.textColor = UIColor.gray
        uidLbl.numberOfLines = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}







