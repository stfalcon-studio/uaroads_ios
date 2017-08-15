//
//  FooterText.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/13/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift


class FooterText: UIView {
    let versionLbl = UILabel()
    let uidLbl = UILabel()
    let copyButton = UIButton()
    fileprivate let disposeBag = DisposeBag()
    var copyAction: EmptyHandler?
    
    init() {
        super.init(frame: CGRect.zero)
        
        //setup constraints
        addSubview(versionLbl)
        addSubview(uidLbl)
        addSubview(copyButton)
        
        versionLbl.snp.makeConstraints { (make) in
            make.left.equalTo(15.0)
            make.right.equalTo(-15.0)
            make.top.equalToSuperview().offset(20.0)
        }
        
        copyButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.right.equalTo(-15)
            make.top.equalTo(versionLbl.snp.bottom)
        }
        
        uidLbl.snp.makeConstraints { (make) in
            make.left.equalTo(versionLbl)
            make.right.equalTo(copyButton.snp.left)
            make.top.equalTo(versionLbl.snp.bottom).offset(10.0)
        }
        
        //setup interface
        versionLbl.font = UIFont.systemFont(ofSize: 12.0)
        versionLbl.textColor = UIColor.gray
        versionLbl.numberOfLines = 0
        
        uidLbl.font = UIFont.systemFont(ofSize: 12.0)
        uidLbl.textColor = UIColor.gray
        uidLbl.numberOfLines = 0
        
        copyButton.setImage(UIImage(named: "copyToClipboard"), for: .normal)
        copyButton
            .rx
            .tap
            .bind { [weak self] in
                self?.copyAction?()
            }
            .addDisposableTo(disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}







