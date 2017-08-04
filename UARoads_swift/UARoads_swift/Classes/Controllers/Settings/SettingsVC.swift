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

class SettingsVC: BaseTVC {
    
    let viewModel = SettingsViewModel()
    
    // MARK: Overriden funcs
    
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
    
    
    // MARK: Private funcs
    
    fileprivate func signInButtonTapped() {
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! SettingsTFCell
        if cell.mainTF.text?.characters.count == 0 || cell.mainTF.textColor == UIColor.red {
            AlertManager.showAlertCheckEmail(viewController: self)
            return
        }
        
        let email = cell.mainTF.text
        if email == nil || email?.length == 0 {
            return
        }
        
        if NetworkConnectionManager.shared.networkStatus == .notReachable {
            AlertManager.showAlertServerConnectionError(viewController: self)
            return
        }
       
        authorizeUser(with: email!)
    }
    
    fileprivate func configureEmailCell(_ cell: SettingsTFCell) {
        cell.update(email: SettingsManager.sharedInstance.email)
        
        cell.mainTF
            .rx
            .controlEvent(.editingDidEndOnExit)
            .bind { [weak self] in
                self?.view.endEditing(true)
            }
            .addDisposableTo(disposeBag)
        
        cell.action = { [weak self] in
            SettingsManager.sharedInstance.email = nil
            self?.tableView.reloadData()
        }
    }
    
    fileprivate func configureSwitchCell(_ cell: SettingsSwitchCell, at indexPath: IndexPath) {
        let settingsType = SettingsParameters(rawValue: indexPath.row)!
        cell.mainTitleLbl.text = settingsType.titleForCell()
        
        switch settingsType {
        case .sendDataOnlyViaWiFi:
            cell.switcher.setOn(SettingsManager.sharedInstance.sendDataOnlyWiFi, animated: false)
        case .autostartRecordRoutes:
            cell.switcher.setOn(SettingsManager.sharedInstance.routeRecordingAutostart, animated: false)
        case .sendTracksAutomatically:
            cell.switcher.setOn(SettingsManager.sharedInstance.sendTracksAutomatically, animated: false)
        }
        
        addSwitchAction(for: cell, with: settingsType)
    }
    
    private func authorizeUser(with email: String) {
        HUDManager.sharedInstance.show(from: self)
        NetworkManager.sharedInstance.authorizeDevice(email: email, handler: { [weak self] success in
            if !success {
                AlertManager.showAlertRegisterDevieceError(viewController: self)
            } else {
                SettingsManager.sharedInstance.email = email
                self?.tableView.reloadData()
            }
            HUDManager.sharedInstance.hide()
        })
    }
    
    private func addSwitchAction(for cell: SettingsSwitchCell, with settingsType: SettingsParameters) {
        switch settingsType {
        case .sendDataOnlyViaWiFi:
            cell.switcher
                .rx
                .value
                .bind(onNext: { val in
                    SettingsManager.sharedInstance.sendDataOnlyWiFi = val
                    AnalyticManager.sharedInstance.reportEvent(category: "Settings", action: "Send Only WiFi")
                })
                .addDisposableTo(disposeBag)
        case .autostartRecordRoutes:
            cell.switcher
                .rx
                .value
                .bind(onNext: { val in
                    SettingsManager.sharedInstance.routeRecordingAutostart = val
                    AutostartManager.sharedInstance.setAutostartActive(val)
                    AnalyticManager.sharedInstance.reportEvent(category: "Settings", action: "Auto Record")
                })
                .addDisposableTo(disposeBag)
        case .sendTracksAutomatically:
            cell.switcher
                .rx
                .value
                .subscribe(onNext: { value in
                    SettingsManager.sharedInstance.sendTracksAutomatically = value
                    AnalyticManager.sharedInstance.reportEvent(category: "Settings", action: "Send Tracks Automatically")
                })
                .addDisposableTo(disposeBag)
        }
    }
    
}

extension SettingsVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let currSection = SettingSection(rawValue: section) else {
            return 0
        }
        return currSection.numberOfRows()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingSection.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let currSection = SettingSection(rawValue: section) else {
            return nil
        }
        return currSection.titleForHeader()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footerView = viewModel.viewForFooter(in: section) else {
            return nil
        }
        
        if let footer = footerView as? FooterSignIn {
            footer.action = { [weak self] in
                self?.signInButtonTapped()
            }
        }
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let section = SettingSection(rawValue: section) else { return 0 }
        return viewModel.heightForFooter(in: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = SettingSection(rawValue: indexPath.section)!
        var cell = UITableViewCell()
        switch section {
        case .signIn:
            let cellEmail = tableView.dequeueReusableCell(withIdentifier: "SettingsTFCell") as! SettingsTFCell
            configureEmailCell(cellEmail)
            cell = cellEmail
        case .switchParameters:
            let switchCell = tableView.dequeueReusableCell(withIdentifier: "SettingsSwitchCell") as! SettingsSwitchCell
            configureSwitchCell(switchCell, at: indexPath)
            cell = switchCell
        }
        
        return cell
    }
}



