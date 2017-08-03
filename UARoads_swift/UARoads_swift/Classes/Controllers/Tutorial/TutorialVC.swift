//
//  TutorialVC.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/19/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import UIViewController_ODStatusBar

class TutorialVC: BaseVC {
    fileprivate let scrollView = UIScrollView()
    fileprivate let pageCtrl = UIPageControl()
    fileprivate let continueBtn = UIButton()
    fileprivate let firstContainerView = UIView()
    fileprivate let secondContainerView = UIView()
    fileprivate let firstImView = UIImageView(image: UIImage(named: "slide1"))
    fileprivate let secondImView = UIImageView(image: UIImage(named: "slide2"))
    fileprivate let firstTitleLbl = UILabel()
    fileprivate let secondTitleLbl = UILabel()
    fileprivate let firstDescrLbl = UILabel()
    fileprivate let secondDescrLbl = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
        setupInterface()
        setupRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        od_setStatusBarStyle(.default)
        od_updateStatusBarAppearance(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 2.0, height: view.bounds.height)
    }
    
    func setupConstraints() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(firstContainerView)
        scrollView.addSubview(secondContainerView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        firstContainerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.size.equalTo(view)
            make.left.equalToSuperview()
        }
        
        secondContainerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.size.equalTo(view)
            make.left.equalTo(firstContainerView.snp.right)
        }
        
        firstContainerView.addSubview(firstImView)
        firstContainerView.addSubview(firstTitleLbl)
        firstContainerView.addSubview(firstDescrLbl)
        
        firstImView.snp.makeConstraints { (make) in
            make.left.equalTo(30.0)
            make.right.equalTo(-30.0)
            make.top.equalToSuperview().offset(70.0)
        }
        
        firstTitleLbl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(firstImView.snp.bottom).offset(25.0)
        }
        
        firstDescrLbl.snp.makeConstraints { (make) in
            make.top.equalTo(firstTitleLbl.snp.bottom).offset(15.0)
            make.left.equalTo(20.0)
            make.right.equalTo(-20.0)
        }
        
        secondContainerView.addSubview(secondImView)
        secondContainerView.addSubview(secondTitleLbl)
        secondContainerView.addSubview(secondDescrLbl)
        
        secondImView.snp.makeConstraints { (make) in
            make.left.equalTo(30.0)
            make.right.equalTo(-30.0)
            make.top.equalToSuperview().offset(70.0)
        }
        
        secondTitleLbl.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(secondImView.snp.bottom).offset(25.0)
        }
        
        secondDescrLbl.snp.makeConstraints { (make) in
            make.top.equalTo(secondTitleLbl.snp.bottom).offset(15.0)
            make.left.equalTo(20.0)
            make.right.equalTo(-20.0)
        }
        
        view.addSubview(pageCtrl)
        view.addSubview(continueBtn)
        
        continueBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-15.0)
            make.height.equalTo(45.0)
            make.centerX.equalToSuperview()
        }
        
        pageCtrl.snp.makeConstraints { (make) in
            make.centerX.equalTo(continueBtn)
            make.bottom.equalTo(continueBtn.snp.top).offset(-10.0)
        }
    }
    
    func setupInterface() {
        continueBtn.setTitle(NSLocalizedString("continue", comment: "continueBtn").uppercased(), for: .normal)
        continueBtn.setTitleColor(UIColor.colorPrimaryDark, for: .normal)
        continueBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12.0)
        
        pageCtrl.numberOfPages = 2
        pageCtrl.currentPage = 0
        pageCtrl.currentPageIndicatorTintColor = UIColor.black
        pageCtrl.pageIndicatorTintColor = UIColor.lightGray
        
        scrollView.isUserInteractionEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        
        firstImView.contentMode = .scaleAspectFit
        secondImView.contentMode = .scaleAspectFit
        
        firstTitleLbl.text = NSLocalizedString("Build routes", comment: "")
        firstTitleLbl.font = UIFont.boldSystemFont(ofSize: 16.0)
        firstTitleLbl.textColor = UIColor.black
        
        firstDescrLbl.text = NSLocalizedString("Build routes through the best Ukrainian roads in view of road quality.", comment: "")
        firstDescrLbl.font = UIFont.systemFont(ofSize: 12.0)
        firstDescrLbl.textColor = UIColor.gray
        firstDescrLbl.numberOfLines = 0
        firstDescrLbl.textAlignment = .center
        
        secondTitleLbl.text = NSLocalizedString("Collect statistics", comment: "")
        secondTitleLbl.font = UIFont.boldSystemFont(ofSize: 16.0)
        secondTitleLbl.textColor = UIColor.black
        
        secondDescrLbl.text = NSLocalizedString("Collect road quality statistics with help of autimatic pit fixation.", comment: "")
        secondDescrLbl.font = UIFont.systemFont(ofSize: 12.0)
        secondDescrLbl.textColor = UIColor.gray
        secondDescrLbl.numberOfLines = 0
        secondDescrLbl.textAlignment = .center
    }
    
    func setupRx() {
        continueBtn
            .rx
            .tap
            .bind {
                SettingsManager.sharedInstance.firstLaunch = "firstLaunch"
                //show main TabBarVC
                (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = TabBarVC()
            }
            .addDisposableTo(disposeBag)
        
        scrollView
            .rx
            .contentOffset
            .bind(onNext: { [weak self] offset in
                if offset.x > 0.0 {
                    self?.pageCtrl.currentPage = 1
                } else {
                    self?.pageCtrl.currentPage = 0
                }
            })
            .addDisposableTo(disposeBag)
    }
}










