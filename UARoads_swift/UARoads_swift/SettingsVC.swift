//
//  SettingsVC.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import RxSwift
import StfalconSwiftExtensions
import UHBConnectivityManager

class SettingsVC: BaseTVC {
    fileprivate let dataSourceTitle = [
        NSLocalizedString("Send data only via WiFi", comment: "title"),
        NSLocalizedString("Route recording autostart", comment: "title"),
        NSLocalizedString("Show map / graph", comment: "title"),
//        NSLocalizedString("Enable pit sounds", comment: "title")
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
}

extension SettingsVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return dataSourceTitle.count
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
            if SettingsManager.sharedInstance.email != nil {
                return nil
            }
            
            let footer = FooterSignIn()
            footer.action = { [weak self] in
                let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SettingsTFCell
                if cell.mainTF.text?.characters.count == 0 || cell.mainTF.textColor == UIColor.red {
                    AlertManager.showAlertCheckEmail(viewController: self)
                    return
                }
                
                if let email = cell.mainTF.text {
                    //authorize user
                    if UHBConnectivityManager.shared().isConnected() == true {
                        HUDManager.sharedInstance.show(from: self!)
                        NetworkManager.sharedInstance.authorizeDevice(email: email, handler: { [weak self] val in
                            if !val {
                                AlertManager.showAlertRegisterDevieceError(viewController: self)
                            } else {
                                //save email to Defaults
                                SettingsManager.sharedInstance.email = email
                                
                                //update UI
                                self?.tableView.reloadData()
                            }
                            HUDManager.sharedInstance.hide()
                        })
                    }
                }
            }
            footer.textLbl.text = NSLocalizedString("Authorized users can view their site statistics, get in TOP, gain reward for their achievements.", comment: "footerTitle")
            
            return footer
            
        } else {
            let footer = FooterText()
            footer.versionLbl.text = NSLocalizedString("Version: ", comment: "version") + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
            footer.uidLbl.text = "UID: " + (UIDevice.current.identifierForVendor?.uuidString ?? "")
            
            return footer
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let height: CGFloat = 100.0
        if section == 0 {
            return SettingsManager.sharedInstance.email != nil ? 0.0 : height
        }
        return height
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
            
            cellEmail.action = { [weak self] in
                SettingsManager.sharedInstance.email = nil
                self?.tableView.reloadData()
            }
            
            cellEmail.update(email: SettingsManager.sharedInstance.email)
            
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
                        AnalyticManager.sharedInstance.reportEvent(category: "Settings", action: "Send Only WiFi")
                    })
                    .addDisposableTo(disposeBag)
            case 1:
                cell.switcher.setOn(SettingsManager.sharedInstance.routeRecordingAutostart, animated: false)
                cell.switcher
                    .rx
                    .value
                    .bind(onNext: { val in
                        SettingsManager.sharedInstance.routeRecordingAutostart = val
                        AutostartManager.sharedInstance.setAutostartActive(val)
                        AnalyticManager.sharedInstance.reportEvent(category: "Settings", action: "Auto Record")
                    })
                    .addDisposableTo(disposeBag)
                
            case 2:
                cell.switcher.setOn(SettingsManager.sharedInstance.showGraph, animated: false)
                cell.switcher
                    .rx
                    .value
                    .bind(onNext: { val in
                        SettingsManager.sharedInstance.showGraph = val
                        AnalyticManager.sharedInstance.reportEvent(category: "Settings", action: "Show Map")
                    })
                    .addDisposableTo(disposeBag)
                
            case 3:
                cell.switcher.setOn(SettingsManager.sharedInstance.enableSound, animated: false)
                cell.switcher
                    .rx
                    .value
                    .bind(onNext: { val in
                        SettingsManager.sharedInstance.enableSound = val
                        AnalyticManager.sharedInstance.reportEvent(category: "Settings", action: "Pit Sound")
                    })
                    .addDisposableTo(disposeBag)
                
            default: break
            }
            return cell
        }
        
        return UITableViewCell()
    }
}











