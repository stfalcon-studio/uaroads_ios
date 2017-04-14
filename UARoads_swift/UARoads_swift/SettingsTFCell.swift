//
//  SettingsTFCell.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/13/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import TSValidatedTextField

class SettingsTFCell: BaseCell {
    fileprivate let signOutBtn = UIButton()
    let mainTF = TSValidatedTextField()
    var action: EmptyHandler?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //setup constraints
        addSubview(mainTF)
        addSubview(signOutBtn)
        
        mainTF.snp.makeConstraints { (make) in
            make.left.equalTo(15.0)
            make.right.equalTo(signOutBtn.snp.left).offset(-10.0)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        signOutBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-15.0)
            make.top.equalTo(5.0)
            make.bottom.equalTo(-5.0)
            make.width.equalTo(75.0)
        }
        
        //setup interface
        mainTF.regexpValidColor = UIColor.black
        mainTF.regexpInvalidColor = UIColor.red
        mainTF.regexpPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        mainTF.keyboardType = .emailAddress
        mainTF.placeholder = NSLocalizedString("Enter e-mail", comment: "emailPlaceholder")
        mainTF.font = UIFont.systemFont(ofSize: 14.0)
        mainTF.autocorrectionType = .no
        mainTF.autocapitalizationType = .none
        
        signOutBtn.setTitle(NSLocalizedString("Sign Out", comment: "signOutBtn"), for: .normal)
        signOutBtn.setTitleColor(UIColor.navBar, for: .normal)
        signOutBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        signOutBtn.layer.borderColor = UIColor.navBar.cgColor
        signOutBtn.layer.borderWidth = 1.0
        signOutBtn.layer.cornerRadius = 4.0
        signOutBtn.layer.masksToBounds = true
        signOutBtn
            .rx
            .tap
            .bind { [weak self] in
                self?.action?()
            }
            .addDisposableTo(disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(email: String?) {
        if let email = email {
            mainTF.isUserInteractionEnabled = false
            mainTF.text = email
            signOutBtn.isHidden = false
        } else {
            signOutBtn.isHidden = true
            mainTF.isUserInteractionEnabled = true
            mainTF.text = ""
        }
    }
}








