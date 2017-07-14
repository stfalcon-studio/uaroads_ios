//
//  RecordVC.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import CoreLocation

class RecordVC: BaseVC {
    fileprivate let mainLbl = UILabel()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        graphView.isHidden = !SettingsManager.sharedInstance.showGraph
    }
    
    func setupConstraints() {
        view.addSubview(mainLbl)
        view.addSubview(lastSessionDetailLbl)
        view.addSubview(lastSessionLbl)
        view.addSubview(allSessionDetailLbl)
        view.addSubview(allSessionsLbl)
        view.addSubview(graphView)
        view.addSubview(startBtn)
        view.addSubview(pauseBtn)
        view.addSubview(stopBtn)
        
        view.sendSubview(toBack: graphView)
        
        mainLbl.snp.makeConstraints { (make) in
            make.top.equalTo(70.0)
            make.left.equalTo(15.0)
            make.right.equalTo(-15.0)
        }
        
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
        
        allSessionsLbl.text = NSLocalizedString("All sessions", comment: "All sessions")
        allSessionsLbl.textAlignment = .center
        allSessionsLbl.font = UIFont.systemFont(ofSize: 12.0)
        allSessionsLbl.textColor = UIColor.colorPrimaryDark
        
        lastSessionLbl.text = NSLocalizedString("Last session", comment: "Last session")
        lastSessionLbl.textAlignment = .center
        lastSessionLbl.font = UIFont.systemFont(ofSize: 12.0)
        lastSessionLbl.textColor = UIColor.colorPrimaryDark
        
        allSessionDetailLbl.text = "0.00"
        allSessionDetailLbl.textColor = UIColor.colorPrimaryDark
        allSessionDetailLbl.font = UIFont.systemFont(ofSize: 25.0)
        allSessionDetailLbl.textAlignment = .center
        
        lastSessionDetailLbl.text = "0.0 km"
        lastSessionDetailLbl.textColor = UIColor.colorPrimaryDark
        lastSessionDetailLbl.font = UIFont.systemFont(ofSize: 25.0)
        lastSessionDetailLbl.textAlignment = .center
        
        startBtn.tintColor = UIColor.colorAccent
        startBtn.setBackgroundImage(UIImage(named: "btn_start_normal"), for: .normal)
        startBtn.setBackgroundImage(UIImage(named: "btn_start_pressed"), for: .highlighted)
        startBtn.setTitle(NSLocalizedString("start recording", comment: "startBtn").uppercased(), for: .normal)
        startBtn.titleLabel?.font = UIFont.systemFont(ofSize: 30.0)
        startBtn.titleLabel?.numberOfLines = 2
        startBtn.titleLabel?.textAlignment = .center
        startBtn.setTitleColor(UIColor.colorPrimaryDark, for: .normal)
        
        pauseBtn.tintColor = UIColor.colorAccent
        pauseBtn.setBackgroundImage(UIImage(named: "btn_pause_normal"), for: .normal)
        pauseBtn.setBackgroundImage(UIImage(named: "btn_pause_pressed"), for: .highlighted)
        pauseBtn.setTitle(NSLocalizedString("pause", comment: "pause").uppercased(), for: .normal)
        pauseBtn.setTitle(NSLocalizedString("resume", comment: "resume").uppercased(), for: .selected)
        pauseBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
        pauseBtn.titleLabel?.textAlignment = .center
        pauseBtn.setTitleColor(UIColor.colorPrimaryDark, for: .normal)
        
        stopBtn.tintColor = UIColor.colorAccent
        stopBtn.setBackgroundImage(UIImage(named: "btn_stop_normal"), for: .normal)
        stopBtn.setBackgroundImage(UIImage(named: "btn_stop_pressed"), for: .highlighted)
        stopBtn.setTitle(NSLocalizedString("stop", comment: "pause").uppercased(), for: .normal)
        stopBtn.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
        stopBtn.titleLabel?.textAlignment = .center
        stopBtn.setTitleColor(UIColor.colorPrimaryDark, for: .normal)
        
        pauseBtn.isHidden = true
        stopBtn.isHidden = true
        lastSessionLbl.isHidden = true
        lastSessionDetailLbl.isHidden = true
        allSessionsLbl.isHidden = true
        allSessionDetailLbl.isHidden = true
        
        RecordService.sharedInstance.delegate = self
    }
    
    func setupRx() {
        RecordService.sharedInstance.onMotionStart = { [unowned self] point, filtered in
            if self.graphView.isHidden == false {
                self.graphView.addValue(CGFloat(point), isFiltered: filtered)
            }
        }
        
        RecordService.sharedInstance.onMotionStop = { [unowned self] in
            self.graphView.clear()
        }
        
        startBtn
            .rx
            .tap
            .bind { [weak self] in
                if UIApplication.shared.backgroundRefreshStatus == .available {
                    RecordService.sharedInstance.startRecording()
                    self?.lastSessionLbl.text = NSLocalizedString("Current session", comment: "lastSessionLbl")
                    self?.allSessionsLbl.text = NSLocalizedString("Shaking force", comment: "allSessionsLbl")
                    self?.pauseBtn.isHidden = false
                    self?.stopBtn.isHidden = false
                    self?.startBtn.isHidden = true
                    self?.mainLbl.isHidden = true
                    self?.allSessionsLbl.isHidden = false
                    self?.allSessionDetailLbl.isHidden = false
                    self?.lastSessionLbl.isHidden = false
                    self?.lastSessionDetailLbl.isHidden = false
                } else {
                    AlertManager.showAlertBgRefreshDisabled(viewController: self)
                }
            }
            .addDisposableTo(disposeBag)
        
        pauseBtn
            .rx
            .tap
            .bind { [weak self] in
                if let strongSelf = self {
                    strongSelf.pauseBtn.isSelected = !strongSelf.pauseBtn.isSelected
                    if RecordService.sharedInstance.motionManager.status == .active {
                        RecordService.sharedInstance.pauseRecording()
                    } else {
                        RecordService.sharedInstance.resumeRecording()
                    }
                }
            }
            .addDisposableTo(disposeBag)
        
        stopBtn
            .rx
            .tap
            .bind { [weak self] in
                self?.allSessionsLbl.text = NSLocalizedString("All sessions", comment: "All sessions")
                self?.lastSessionLbl.text = NSLocalizedString("Last session", comment: "Last session")
                self?.pauseBtn.isHidden = true
                self?.stopBtn.isHidden = true
                self?.startBtn.isHidden = false
                self?.mainLbl.isHidden = false
                self?.allSessionsLbl.isHidden = true
                self?.allSessionDetailLbl.isHidden = true
                self?.lastSessionLbl.isHidden = true
                self?.lastSessionDetailLbl.isHidden = true
                RecordService.sharedInstance.stopRecording()
            }
            .addDisposableTo(disposeBag)
        
        RecordService.sharedInstance.motionManager.delegate = self
    }
}

extension RecordVC: MotionManagerDelegate {
    
    func statusChanged(newStatus: MotionStatus) {
        //
    }
}

extension RecordVC: RecordServiceDelegate {
    func trackDistanceUpdated(trackDist: Double) {
        lastSessionDetailLbl.text = NSString(format: "%.2f km", trackDist/1000.0) as String
    }
    
    func maxPitUpdated(maxPit: Double) {
        allSessionDetailLbl.text = NSString(format: "%.2f", maxPit) as String
    }
}








