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
    fileprivate let signOut = UIButton()
    let mainTF = TSValidatedTextField()
    var action: EmptyHandler?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //setup constraints
        addSubview(mainTF)
        addSubview(signOut)
        
        mainTF.snp.makeConstraints { (make) in
            make.left.equalTo(15.0)
            make.right.equalTo(signOut.snp.left).offset(-10.0)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        signOut.snp.makeConstraints { (make) in
            make.right.equalTo(-15.0)
            make.top.equalTo(5.0)
            make.bottom.equalTo(-5.0)
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
        
        signOut.setTitle(NSLocalizedString("Sign Out", comment: "signOutBtn"), for: .normal)
        signOut.setTitleColor(UIColor.navBar, for: .normal)
        signOut.layer.borderColor = UIColor.navBar.cgColor
        signOut.layer.borderWidth = 1.0
        signOut.layer.cornerRadius = 4.0
        signOut.layer.masksToBounds = true
        signOut
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
            signOut.isHidden = false
        } else {
            signOut.isHidden = true
            mainTF.isUserInteractionEnabled = true
            mainTF.text = ""
        }
    }
}








