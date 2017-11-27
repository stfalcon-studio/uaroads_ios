//
//  RecordedCell.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/10/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import WebKit

class RecordedCell: BaseCell {
    let dateLbl = UILabel()
    let stateLbl = UILabel()
    let distLbl = UILabel()
    let webView = WKWebView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //setup constraints
        addSubview(dateLbl)
        addSubview(stateLbl)
        addSubview(distLbl)
        addSubview(webView)
        
        webView.isUserInteractionEnabled  = false
//        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        
        dateLbl.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8.0)
            make.left.equalToSuperview().offset(15.0)
        }
        
        stateLbl.snp.makeConstraints { (make) in
            make.left.equalTo(dateLbl)
            make.top.equalTo(dateLbl.snp.bottom).offset(3.0)
//            make.bottom.equalToSuperview().offset(-8.0)
        }
        
        distLbl.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15.0)
            make.top.equalToSuperview().offset(10)
        }
        
        webView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview()
            make.top.equalTo(stateLbl.snp.bottom)
        }
        
        //setup interface
        separatorInset = UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0)
        
        stateLbl.textColor = UIColor.lightGray
        stateLbl.font = UIFont.systemFont(ofSize: 12.0)
        
        distLbl.textColor = UIColor.colorPrimaryDark
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureFromTrack(_ track:TrackModel) {
        DateManager.sharedInstance.setFormat("dd MMMM yyyy HH:mm")
        dateLbl.text = DateManager.sharedInstance.getDateFormatted(track.date)
        stateLbl.text = TrackStatus(rawValue: track.status)?.title()
        distLbl.text = NSString(format: "%.2f ", track.distance / 1000.0) as String + "km".localized
        guard let firstCoordinate = track.pits.first,
            let lastCoordinate = track.pits.last else {
            return
        }
        
        let urlStr = "http://uaroads.com/routing/\(firstCoordinate.latitude),\(firstCoordinate.longitude)/\(lastCoordinate.latitude),\(lastCoordinate.longitude)?mob=true"
        let req = URLRequest(url: URL(string: urlStr)!)
        webView.load(req)
    }
}

