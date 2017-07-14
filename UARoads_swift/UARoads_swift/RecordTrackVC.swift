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
    
    @IBOutlet weak var lastTrackContainerView: UIView!
    @IBOutlet weak var currentTrackView: CurrentTrackView!
    @IBOutlet weak var lastTrackLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var lastTrackDescrLabel: UILabel!
    @IBOutlet weak var totalTracksDescrLabel: UILabel!
    @IBOutlet weak var pauseStopContainerView: UIView!
    @IBOutlet weak var startButton: BorderButton!
    @IBOutlet weak var pauseButton: ArcButton!
    @IBOutlet weak var stopButton: ArcButton!
    
    
    fileprivate let graphView = GraphView()
    

    // MARK: Overriden funcs
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Record"
      
        RecordService.sharedInstance.motionManager.delegate = self
        RecordService.sharedInstance.delegate = self
        
        setupInterface()
        setupRx()
        updateUIForRecordStop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        graphView.isHidden = !SettingsManager.sharedInstance.showGraph
    }

    

    // MARK: Action funcs
    
    @IBAction func startButtonTapped(_ sender: BorderButton) {
        if UIApplication.shared.backgroundRefreshStatus == .available {
            RecordService.sharedInstance.startRecording()
            startButton.isHidden = true
            pauseStopContainerView.isHidden = false
            currentTrackView.isHidden = false
            lastTrackContainerView.isHidden = true
        } else {
            AlertManager.showAlertBgRefreshDisabled(viewController: self)
        }
    }
    
    @IBAction func pauseButtonTapped(_ sender: ArcButton) {
        pauseButton.isSelected = !pauseButton.isSelected
        
        if RecordService.sharedInstance.motionManager.status == .active {
            RecordService.sharedInstance.pauseRecording()
        } else {
            RecordService.sharedInstance.resumeRecording()
        }
    }
    
    @IBAction func stopButtonTapped(_ sender: ArcButton) {
        RecordService.sharedInstance.stopRecording()
        updateUIForRecordStop()
    }
    
    
    // MARK: Private funcs
    
    private func setupInterface() {
        pauseStopContainerView.layer.cornerRadius = pauseStopContainerView.frame.size.width / 2
        pauseStopContainerView.clipsToBounds = true
        
        let lrPadding: CGFloat = 10
        self.view.addSubview(graphView)
        graphView.snp.makeConstraints { (make) in
            make.left.equalTo(lrPadding)
            make.right.equalTo(-lrPadding)
            make.top.equalTo(startButton.snp.bottom)
            make.bottom.equalToSuperview().offset(-40)
        }
    }
    
    private func updateUIForRecordStop() {
        startButton.isHidden = false
        pauseStopContainerView.isHidden = true
        currentTrackView.isHidden = true
        lastTrackContainerView.isHidden = false
        setLastTrackDistance()
    }
    
    private func setLastTrackDistance() {
        if let track: TrackModel = RealmHelper.objects(type: TrackModel.self)?.sorted(byKeyPath: "date", ascending: true).last {
            lastTrackLabel.attributedText = attributedStringForDistance(track.distance)
        }
    }
    
    private func attributedStringForDistance(_ distance: CGFloat) -> NSMutableAttributedString {
        let distanceStr = NSString(format:"%.2f", distance / 1000) as String
        let kmStr = "km"
        let text = distanceStr + kmStr
        let rangeKm = text.nsRange(of: kmStr)
        let attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 19),
                          NSForegroundColorAttributeName: UIColor.darkGray]
        let attrStr = NSMutableAttributedString(string: text)
        attrStr.addAttributes(attributes, range: rangeKm)
        return attrStr
    }
    
    
    private func setupRx() {
        RecordService.sharedInstance.onMotionStart = { [unowned self] point, filtered in
            if self.graphView.isHidden == false {
                self.graphView.addValue(CGFloat(point), isFiltered: filtered)
            }
        }
        
        RecordService.sharedInstance.onMotionStop = { [unowned self] in
            self.graphView.clear()
        }
    }
}


extension RecordTrackVC: MotionManagerDelegate {
    
    func statusChanged(newStatus: MotionStatus) {
        //
    }
}

extension RecordTrackVC: RecordServiceDelegate {
    func trackDistanceUpdated(trackDist: Double) {
        currentTrackView.setDistance(trackDist)
    }
    
    func maxPitUpdated(maxPit: Double) {
//        allSessionDetailLbl.text = NSString(format: "%.2f", maxPit) as String
    }
}
