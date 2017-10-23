//
//  RecordTrackVC.swift
//  UARoads_swift
//
//  Created by Roman Rybachenko on 7/13/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import CoreLocation
import StfalconSwiftExtensions

class RecordTrackVC: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var lastTrackContainerView: UIStackView!
    @IBOutlet weak var loginInfoContainerView: UIStackView!
    @IBOutlet weak var totalTrackContainerView: UIStackView!
    @IBOutlet weak var currentTrackView: CurrentTrackView!
    @IBOutlet weak var lastTrackLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var lastTrackDescrLabel: UILabel!
    @IBOutlet weak var totalTracksDescrLabel: UILabel!
    @IBOutlet weak var pauseStopContainerView: UIView!
    @IBOutlet weak var startButton: BorderButton! {
        didSet {
            startButton.layer.cornerRadius = startButton.frame.height
        }
    }
    @IBOutlet weak var pauseButton: ArcButton!
    @IBOutlet weak var stopButton: ArcButton!
    @IBOutlet weak var signInButton: UIButton! {
        didSet {
            signInButton.setTitle("SettingsVC.signInFooter.signInButtonTitle".localized, for: .normal)
            signInButton.setTitleColor(UIColor.white, for: .normal)
            signInButton.backgroundColor = UIColor.colorPrimaryDark
            signInButton.layer.cornerRadius = 4.0
            signInButton.layer.masksToBounds = true
            signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        }
    }
    @IBOutlet weak var sendDistanceLabel: UILabel! {
        didSet {
            sendDistanceLabel.text = "RecordTrackVC.sendDistanceToServer".localized
        }
    }
    @IBOutlet weak var graphView: GraphView!
    
//    
//    fileprivate let graphView = GraphView()
    let viewModel: RecordTrackViewModel = RecordTrackViewModel()
    

    // MARK: Overriden funcs
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("RecordTrackVC.title", comment: "")
      
        RecordService.shared.motionManager.delegate = self
        
        setupInterface()
        setupRx()
        updateUIForRecordStop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIAuthUser()
        UIApplication.shared.statusBarStyle = .lightContent
        
        viewModel.getUserStatistic(completion: { (response, error) in
            pl(response)
        })
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pauseStopContainerView.layer.cornerRadius = pauseStopContainerView.frame.size.width / 2
    }
    

    // MARK: Action funcs
    
    @IBAction func signInTapped(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 3
    }
    
    @IBAction func startButtonTapped(_ sender: BorderButton) {
        if UIApplication.shared.backgroundRefreshStatus == .available {
            RecordService.shared.startRecording()
            updateUiForRecordStart()
        } else {
            AlertManager.showAlertBgRefreshDisabled(viewController: self)
        }
    }
    
    @IBAction func pauseButtonTapped(_ sender: ArcButton) {
        if RecordService.shared.motionManager.status == .active {
            RecordService.shared.pauseRecording()
        } else {
            RecordService.shared.resumeRecording()
        }
        
        updateUiForRecordPause()
    }
    
    @IBAction func stopButtonTapped(_ sender: ArcButton) {
        RecordService.shared.stopRecording()
        updateUIForRecordStop()
    }
    
    func updateUiForRecordPause() {
        if RecordService.shared.motionManager.status == .paused {
            pauseButton.isSelected = true
        } else if RecordService.shared.motionManager.status == .active {
            pauseButton.isSelected = false
        }
    }
    
    func updateUiForRecordStart() {
        startButton.isHidden = true
        pauseStopContainerView.isHidden = false
        currentTrackView.isHidden = false
        lastTrackContainerView.isHidden = true
        loginInfoContainerView.isHidden = true
        totalTrackContainerView.isHidden = true
    }
    
    func updateUIForRecordStop() {
        pauseButton.isSelected = false
        startButton.isHidden = false
        pauseStopContainerView.isHidden = true
        currentTrackView.isHidden = true
        lastTrackContainerView.isHidden = false
        
        lastTrackLabel.attributedText = viewModel.attributedStringLastTrackDistance()
        updateUIAuthUser()
    }
    
    
    // MARK: Private funcs
    
    private func updateUIAuthUser() {
        totalTrackContainerView.isHidden = !SettingsManager.sharedInstance.isAuth
        loginInfoContainerView.isHidden = SettingsManager.sharedInstance.isAuth
    }
    
    private func setupInterface() {
        let startButtonTitle = "RecordTrackVC.startButtonTitle".localized.uppercased()
        startButton.setTitle(startButtonTitle, for: .normal)
        let pauseBtnTitleNormal = "RecordTrackVC.pauseButtonTitle".localized.uppercased()
        let pauseBtnTitleSelected = "RecordTrackVC.pauseButtonTitleSelected".localized.uppercased()
        pauseButton.setTitle(pauseBtnTitleNormal, for: .normal)
        pauseButton.setTitle(pauseBtnTitleSelected, for: .selected)
        
        let stopButtonTitle = "RecordTrackVC.stopButtonTitle".localized.uppercased()
        stopButton.setTitle(stopButtonTitle, for: .normal)
        
        lastTrackDescrLabel.text = "RecordTrackVC.lastTrackLabel".localized
        totalTracksDescrLabel.text = "RecordTrackVC.totalDistLabel".localized
        
        pauseStopContainerView.clipsToBounds = true
        
//        let lrPadding: CGFloat = 10
//        self.view.addSubview(graphView)
//        graphView.snp.makeConstraints { (make) in
//            make.left.equalTo(lrPadding)
//            make.right.equalTo(-lrPadding)
//            make.top.equalTo(startButton.snp.bottom)
//            make.bottom.equalToSuperview().offset(-40)
//        }
    }
    
    
    private func setupRx() {
        RecordService.shared.onMotionStart = { [unowned self] point, filtered in
            if self.graphView.isHidden == false {
                self.graphView.addValue(CGFloat(point), isFiltered: filtered)
            }
        }
        
        RecordService.shared.onMotionStop = { [unowned self] in
            self.graphView.clear()
        }
        
        RecordService.shared.locationManager.onLocationUpdate = { [unowned self] location in
            let gpsStatus: GPS_Status = self.viewModel.gpsStatus(from: location)
            self.currentTrackView.gpsStatusView.setGpsStatus(gpsStatus)
        }
        
        RecordService.shared.trackDistanceUpdated = { [unowned self] newDistance in
            self.currentTrackView.distanceLabel.text = self.viewModel.distanceStringInKilometers(newDistance)
        }
    }
    
}


extension RecordTrackVC: MotionManagerDelegate {
    
    func statusChanged(newStatus: RecordStatus, oldStatus: RecordStatus) {
        switch newStatus {
        case .paused,
             .pausedForCall:
            updateUiForRecordPause()
        case .active:
            if oldStatus == .notActive {
                updateUiForRecordStart()
            } else if oldStatus == .paused || oldStatus == .pausedForCall {
                updateUiForRecordPause()
            }
        case .notActive:
            updateUIForRecordStop()
        }
    }
}

