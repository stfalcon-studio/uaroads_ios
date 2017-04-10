//
//  RouteBuidVC.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

class RouteBuidVC: BaseVC {
    fileprivate let cancelBtn = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: "cancelBtn"), style: .plain, target: nil, action: nil)
    fileprivate let webView = UIWebView()
    fileprivate let fromLbl = UILabel()
    fileprivate let toLbl = UILabel()
    fileprivate let goBtn = UIButton()
    
    fileprivate var fromModel: SearchResultModel!
    fileprivate var toModel: SearchResultModel!
    
    init(from: SearchResultModel, to: SearchResultModel) {
        super.init()
        
        self.fromModel = from
        self.toModel = to
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupConstraints()
        setupInterface()
        setupRx()
    }
    
    func setupConstraints() {
        view.addSubview(webView)
        view.addSubview(fromLbl)
        view.addSubview(toLbl)
        view.addSubview(goBtn)
        
        goBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50.0)
            make.width.equalToSuperview()
        }
        
        toLbl.snp.makeConstraints { (make) in
            make.left.equalTo(15.0)
            make.right.equalTo(-15.0)
            make.bottom.equalTo(goBtn.snp.top)
            make.height.equalTo(30.0)
        }
        
        fromLbl.snp.makeConstraints { (make) in
            make.left.equalTo(toLbl)
            make.right.equalTo(toLbl)
            make.height.equalTo(toLbl)
            make.bottom.equalTo(toLbl.snp.top)
        }
        
        webView.snp.makeConstraints { (make) in
            make.bottom.equalTo(fromLbl.snp.top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    
    func setupInterface() {
        title = NSLocalizedString("Route", comment: "title")
        
        cancelBtn.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = cancelBtn
        
        let attrFrom = NSMutableAttributedString(string: NSLocalizedString("from", comment: "from") + " ",
                                          attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
        let attrFromName = NSAttributedString(string: fromModel.locationName!, attributes: [NSForegroundColorAttributeName:UIColor.black])
        attrFrom.insert(attrFromName, at: attrFrom.length)
        fromLbl.attributedText = attrFrom
        
        let attrTo = NSMutableAttributedString(string: NSLocalizedString("to", comment: "to") + " ", attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
        let attrToName = NSAttributedString(string: toModel.locationName!, attributes: [NSForegroundColorAttributeName:UIColor.black])
        attrTo.insert(attrToName, at: attrTo.length)
        toLbl.attributedText = attrTo
        
        goBtn.setTitle(NSLocalizedString("GO!", comment: "goBtn"), for: .normal)
        goBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        goBtn.backgroundColor = UIColor.buildBtn
        
        fromLbl.font = UIFont.systemFont(ofSize: 14.0)
        toLbl.font = UIFont.systemFont(ofSize: 14.0)
    }
    
    func setupRx() {
        cancelBtn
            .rx
            .tap
            .bindNext { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
            .addDisposableTo(disposeBag)
        
        goBtn
            .rx
            .tap
            .bindNext { [weak self] in
                print("GO!")
            }
            .addDisposableTo(disposeBag)
    }
}








