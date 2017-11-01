//
//  FooterSignIn.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/13/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class FooterSignIn: UIView {
    fileprivate let signInBtn = UIButton()
    fileprivate let disposeBag = DisposeBag()
    var action: EmptyHandler?
    let textLbl = UILabel()
    
    init() {
        super.init(frame: CGRect.zero)
        
        //setup constraints
        addSubview(signInBtn)
        addSubview(textLbl)
        
        signInBtn.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 80.0, height: 40.0))
            make.left.equalTo(15.0)
            make.top.equalTo(10.0)
        }
        
        textLbl.snp.makeConstraints { (make) in
            make.left.equalTo(15.0)
            make.right.equalTo(-15.0)
            make.top.equalTo(signInBtn.snp.bottom).offset(5.0)
        }
        
        //setup interface
        let signInBtnTitle = NSLocalizedString("SettingsVC.signInFooter.signInButtonTitle", comment: "")
        signInBtn.setTitle(signInBtnTitle, for: .normal)
        signInBtn.setTitleColor(UIColor.white, for: .normal)
        signInBtn.backgroundColor = UIColor.colorPrimaryDark
        signInBtn.layer.cornerRadius = 4.0
        signInBtn.layer.masksToBounds = true
        signInBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        
        textLbl.font = UIFont.systemFont(ofSize: 12.0)
        textLbl.textColor = UIColor.gray
        textLbl.numberOfLines = 0
        
        //setup rx
        signInBtn
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
}
