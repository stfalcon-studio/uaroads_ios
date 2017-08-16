//
//  RouteBuidVC.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

class RouteBuidVC: BaseVC {
    private lazy var cancelBtn: UIBarButtonItem = {
        let btnTitle = NSLocalizedString("RouteBuidVC.cancelButtonTitle", comment: "")
        let cancelButton = UIBarButtonItem(title: btnTitle,
                                           style: .plain,
                                           target: nil,
                                           action: nil)
        return cancelButton
    }()
    fileprivate let webView = UIWebView()
    fileprivate let fromLbl = UILabel()
    fileprivate let fromDetailLbl = UILabel()
    fileprivate let toLbl = UILabel()
    fileprivate let toDetailLbl = UILabel()
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
        
        let urlStr = "http://uaroads.com/routing/\(fromModel.locationCoordianate!.latitude),\(fromModel.locationCoordianate!.longitude)/\(toModel.locationCoordianate!.latitude),\(toModel.locationCoordianate!.longitude)?mob=true"
        webView.loadRequest(URLRequest(url: URL(string: urlStr)!))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setupConstraints() {
        view.addSubview(webView)
        view.addSubview(fromLbl)
        view.addSubview(toLbl)
        view.addSubview(goBtn)
        view.addSubview(fromDetailLbl)
        view.addSubview(toDetailLbl)
        
        goBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50.0)
            make.width.equalToSuperview()
        }
        
        toLbl.snp.makeConstraints { (make) in
            make.left.equalTo(15.0)
            make.right.equalTo(-15.0)
            make.bottom.equalTo(goBtn.snp.top).offset(-10.0)
            make.height.equalTo(30.0)
        }
        
        toDetailLbl.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(60.0)
            make.centerY.equalTo(toLbl)
            make.right.equalTo(toLbl)
            make.height.equalTo(toLbl)
        }
        
        fromLbl.snp.makeConstraints { (make) in
            make.left.equalTo(toLbl)
            make.right.equalTo(toLbl)
            make.height.equalTo(toLbl)
            make.bottom.equalTo(toLbl.snp.top)
        }
        
        fromDetailLbl.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(60.0)
            make.height.equalTo(fromLbl)
            make.right.equalTo(fromLbl)
            make.centerY.equalTo(fromLbl)
        }
        
        webView.snp.makeConstraints { (make) in
            make.bottom.equalTo(fromLbl.snp.top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    
    func setupInterface() {
        title = NSLocalizedString("RouteBuidVC.title", comment: "title")
        
        cancelBtn.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = cancelBtn
        
        fromLbl.text = NSLocalizedString("RouteBuidVC.fromLabel", comment: "") + " "
        toLbl.text = NSLocalizedString("RouteBuidVC.toLabel", comment: "") + " "
        
        fromLbl.textColor = UIColor.lightGray
        toLbl.textColor = UIColor.lightGray
        
        fromLbl.font = UIFont.systemFont(ofSize: 14.0)
        toLbl.font = UIFont.systemFont(ofSize: 14.0)
        
        fromDetailLbl.text = fromModel.locationName
        toDetailLbl.text = toModel.locationName
        
        fromDetailLbl.font = UIFont.systemFont(ofSize: 14.0)
        toDetailLbl.font = UIFont.systemFont(ofSize: 14.0)
        
        let goBtnTitle = NSLocalizedString("RouteBuidVC.goButtonTitle", comment: "").uppercased()
        goBtn.setTitle(goBtnTitle, for: .normal)
        goBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        goBtn.backgroundColor = UIColor.colorAccent
        
        webView.scalesPageToFit = true
    }
    
    func setupRx() {
        cancelBtn
            .rx
            .tap
            .bind { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
            .addDisposableTo(disposeBag)
        
        goBtn
            .rx
            .tap
            .bind { [weak self] in
                let storyboard = UIStoryboard(name: "Navigation", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "UARRoadController") as! UARRoadController

                self?.navigationController?.pushViewController(vc, animated: true)
                DispatchQueue.main.async {
                    if let strongSelf = self {
                        vc.requestRoute(withCoordinates: "loc=\(strongSelf.fromModel.locationCoordianate!.latitude),\(strongSelf.fromModel.locationCoordianate!.longitude)&loc=\(strongSelf.toModel.locationCoordianate!.latitude),\(strongSelf.toModel.locationCoordianate!.longitude)")
                    }
                }
            }
            .addDisposableTo(disposeBag)
        
        webView
            .rx
            .didFinishLoad
            .bind {
                
            }
            .addDisposableTo(disposeBag)
    }
}








