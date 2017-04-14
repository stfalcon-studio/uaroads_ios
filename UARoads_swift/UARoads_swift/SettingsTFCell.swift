//
//  SettingsTFCell.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/13/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

class SettingsTFCell: BaseCell {
    let mainTF = UITextField()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //setup constraints
        addSubview(mainTF)
        
        mainTF.snp.makeConstraints { (make) in
            make.left.equalTo(15.0)
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        //setup interface
        mainTF.placeholder = NSLocalizedString("Enter e-mail", comment: "emailPlaceholder")
        mainTF.font = UIFont.systemFont(ofSize: 14.0)
        mainTF.autocorrectionType = .no
        mainTF.returnKeyType = .done
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}








