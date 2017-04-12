//
//  RecordVC.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

class RecordVC: BaseVC {
    fileprivate let lastSessionDetailLbl = UILabel()
    fileprivate let allSessionDetailLbl = UILabel()
    fileprivate let lastSessionLbl = UILabel()
    fileprivate let allSessionsLbl = UILabel()
    fileprivate let graphView = GraphView()
    fileprivate let startBtn = UIButton()
    fileprivate let pauseBtn = UIButton()
    fileprivate let stopBtn = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
        setupInterface()
        setupRx()
    }
    
    func setupConstraints() {
        view.addSubview(lastSessionDetailLbl)
        view.addSubview(lastSessionLbl)
        view.addSubview(allSessionDetailLbl)
        view.addSubview(allSessionsLbl)
        view.addSubview(graphView)
        view.addSubview(startBtn)
        view.addSubview(pauseBtn)
        view.addSubview(stopBtn)
        
        view.sendSubview(toBack: graphView)
        
        lastSessionDetailLbl.snp.makeConstraints { (make) in
            make.left.equalTo(60.0)
            make.top.equalTo(70.0)
        }
        
        lastSessionLbl.snp.makeConstraints { (make) in
            make.centerX.equalTo(lastSessionDetailLbl)
            make.top.equalTo(lastSessionDetailLbl.snp.bottom).offset(5.0)
        }
        
        allSessionDetailLbl.snp.makeConstraints { (make) in
            make.right.equalTo(-60.0)
            make.centerY.equalTo(lastSessionDetailLbl)
        }
        
        allSessionsLbl.snp.makeConstraints { (make) in
            make.centerX.equalTo(allSessionDetailLbl)
            make.top.equalTo(allSessionDetailLbl.snp.bottom).offset(5.0)
        }
        
        graphView.snp.makeConstraints { (make) in
            make.left.equalTo(10.0)
            make.right.equalTo(-10)
            make.top.equalToSuperview()
            make.bottom.equalTo(startBtn.snp.top).offset(-20.0)
        }
        
        startBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 200.0, height: 200.0))
            make.bottom.equalToSuperview().offset(-30.0)
        }
        
        pauseBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(startBtn)
            make.top.equalTo(startBtn)
            make.width.equalTo(startBtn)
            make.height.equalTo(startBtn).offset(-75.0)
        }
        
        stopBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(startBtn)
            make.bottom.equalTo(startBtn)
            make.width.equalTo(startBtn)
            make.height.equalTo(startBtn).offset(-125.0)
        }
    }
    
    func setupInterface() {
        title = NSLocalizedString("Record", comment: "title")
        
        view.backgroundColor = UIColor.navBar
        
        allSessionsLbl.text = NSLocalizedString("All sessions", comment: "All sessions")
        allSessionsLbl.textAlignment = .center
        allSessionsLbl.font = UIFont.systemFont(ofSize: 12.0)
        allSessionsLbl.textColor = UIColor.lightGray
        
        lastSessionLbl.text = NSLocalizedString("Last session", comment: "Last session")
        lastSessionLbl.textAlignment = .center
        lastSessionLbl.font = UIFont.systemFont(ofSize: 12.0)
        lastSessionLbl.textColor = UIColor.lightGray
        
        allSessionDetailLbl.text = "0.0 km"
        allSessionDetailLbl.textColor = UIColor.white
        allSessionDetailLbl.font = UIFont.systemFont(ofSize: 25.0)
        allSessionDetailLbl.textAlignment = .center
        
        lastSessionDetailLbl.text = "0.76"
        lastSessionDetailLbl.textColor = UIColor.white
        lastSessionDetailLbl.font = UIFont.systemFont(ofSize: 25.0)
        lastSessionDetailLbl.textAlignment = .center
        
        startBtn.setBackgroundImage(UIImage(named: "btn_start_normal"), for: .normal)
        startBtn.setBackgroundImage(UIImage(named: "btn_start_pressed"), for: .highlighted)
        startBtn.setTitle(NSLocalizedString("start recording", comment: "startBtn").uppercased(), for: .normal)
        startBtn.titleLabel?.font = UIFont.systemFont(ofSize: 30.0)
        startBtn.titleLabel?.numberOfLines = 2
        startBtn.titleLabel?.textAlignment = .center
        startBtn.setTitleColor(UIColor.white, for: .normal)
        
        pauseBtn.setBackgroundImage(UIImage(named: "btn_pause_normal"), for: .normal)
        pauseBtn.setBackgroundImage(UIImage(named: "btn_pause_pressed"), for: .highlighted)
        pauseBtn.setTitle(NSLocalizedString("pause", comment: "pause").uppercased(), for: .normal)
        pauseBtn.setTitle(NSLocalizedString("resume", comment: "resume").uppercased(), for: .selected)
        pauseBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
        pauseBtn.titleLabel?.textAlignment = .center
        pauseBtn.setTitleColor(UIColor.white, for: .normal)
        
        stopBtn.setBackgroundImage(UIImage(named: "btn_stop_normal"), for: .normal)
        stopBtn.setBackgroundImage(UIImage(named: "btn_stop_pressed"), for: .highlighted)
        stopBtn.setTitle(NSLocalizedString("stop", comment: "pause").uppercased(), for: .normal)
        stopBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
        stopBtn.titleLabel?.textAlignment = .center
        stopBtn.setTitleColor(UIColor.white, for: .normal)
        
        pauseBtn.isHidden = true
        stopBtn.isHidden = true
    }
    
    func setupRx() {
        startBtn
            .rx
            .tap
            .bindNext { [weak self] in
                self?.pauseBtn.isHidden = false
                self?.stopBtn.isHidden = false
                self?.startBtn.isHidden = true
            }
            .addDisposableTo(disposeBag)
        
        pauseBtn
            .rx
            .tap
            .bindNext { [weak self] in
                if let strongSelf = self {
                    strongSelf.pauseBtn.isSelected = !strongSelf.pauseBtn.isSelected
                }
            }
            .addDisposableTo(disposeBag)
        
        stopBtn
            .rx
            .tap
            .bindNext { [weak self] in
                self?.pauseBtn.isHidden = true
                self?.stopBtn.isHidden = true
                self?.startBtn.isHidden = false
            }
            .addDisposableTo(disposeBag)
        
        MotionManager.sharedInstance.delegate = self
        MotionManager.sharedInstance.graphView = graphView
    }
}








