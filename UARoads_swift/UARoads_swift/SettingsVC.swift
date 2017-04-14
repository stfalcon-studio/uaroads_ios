//
//  SettingsVC.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

class SettingsVC: BaseTVC {
    fileprivate let dataSourceTitle = [
        NSLocalizedString("Send data only via WiFi", comment: "title"),
        NSLocalizedString("Route recording autostart", comment: "title"),
        NSLocalizedString("Show map / graph", comment: "title")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInterface()
        setupConstraints()
        setupRx()
    }
    
    func setupConstraints() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func setupInterface() {
        super.setupInterface()
        
        title = NSLocalizedString("Settings", comment: "title")
        
        tableView = UITableView(frame: view.frame, style: .grouped)
        tableView.register(SettingsSwitchCell.self, forCellReuseIdentifier: "SettingsSwitchCell")
        tableView.register(SettingsTFCell.self, forCellReuseIdentifier: "SettingsTFCell")
    }
    
    override func setupRx() {
        super.setupRx()
        
        //
    }
}

extension SettingsVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("user", comment: "userTitle").uppercased()
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let view = FooterSignIn()
            view.action = { [weak self] in
                print("DFJSFSDFS") //TODO:
            }
            view.textLbl.text = NSLocalizedString("Authorized users can view their site statistics, get in TOP, gain reward for their achievements.", comment: "footerTitle")
            
            return view
        } else {
            let view = FooterText()
            view.versionLbl.text = NSLocalizedString("Version: ", comment: "version") + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
            view.uidLbl.text = "UID: " + (UIDevice.current.identifierForVendor?.uuidString ?? "")
            
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSwitchCell") as! SettingsSwitchCell
        let cellEmail = tableView.dequeueReusableCell(withIdentifier: "SettingsTFCell") as! SettingsTFCell
        
        let section = indexPath.section
        let row = indexPath.row
        let item = dataSourceTitle[row]
        
        if section == 0 {
            cellEmail.mainTF
                .rx
                .controlEvent(.editingDidEndOnExit)
                .bind { [weak self] in
                    self?.view.endEditing(true)
                }
                .addDisposableTo(disposeBag)
            
            return cellEmail
            
        } else if section == 1 {
            cell.mainTitleLbl.text = item
            switch row {
            case 0:
                cell.switcher.setOn(SettingsManager.sharedInstance.sendDataOnlyWiFi, animated: false)
                cell.switcher
                    .rx
                    .value
                    .bind(onNext: { val in
                        SettingsManager.sharedInstance.sendDataOnlyWiFi = val
                    })
                    .addDisposableTo(disposeBag)
            case 1:
                cell.switcher.setOn(SettingsManager.sharedInstance.routeRecordingAutostart, animated: false)
                cell.switcher
                    .rx
                    .value
                    .bind(onNext: { val in
                        SettingsManager.sharedInstance.routeRecordingAutostart = val
                    })
                    .addDisposableTo(disposeBag)
                
            case 2:
                cell.switcher.setOn(SettingsManager.sharedInstance.showGraph, animated: false)
                cell.switcher
                    .rx
                    .value
                    .bind(onNext: { val in
                        SettingsManager.sharedInstance.showGraph = val
                    })
                    .addDisposableTo(disposeBag)
                
            default: break
            }
            return cell
        }
        
        return UITableViewCell()
    }
}











