//
//  SettingsViewModel.swift
//  UARoads_swift
//
//  Created by Roman on 7/31/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation


class SettingsViewModel {
   
    func heightForFooter(in section: SettingSection) -> CGFloat {
        let height: CGFloat = 100.0
        if section == .signIn {
            return SettingsManager.sharedInstance.email != nil ? 0.0 : height
        }
        return height
    }
    
    func viewForFooter(in section: Int) -> UIView? {
        guard let currSection = SettingSection(rawValue: section) else {
            return nil
        }
        switch currSection {
        case .signIn:
            return signInFooterView()
        case .switchParameters:
            let footer = FooterText()
            let versionStr = NSLocalizedString("SettingsVC.switchFooter.versionLabel", comment: "")
            footer.versionLbl.text = versionStr + Utilities.appVersion()
            footer.uidLbl.text = "UID: " + Utilities.deviceUID()
            
            return footer
        }
    }
    
    
    // MARK: Private funcs
    
    private func signInFooterView() -> UIView? {
        if SettingsManager.sharedInstance.email != nil {
            return nil
        }
        
        let footer = FooterSignIn()
        footer.textLbl.text = NSLocalizedString("SettingsVC.signInFooter.labelText", comment: "")
        
        return footer
    }
}



enum SettingsParameters: Int {
    case sendDataOnlyViaWiFi
    case sendTracksAutomatically
    case autostartRecordRoutes
    
    static func numberOfRows() -> Int {
        return 3
    }
    
    func titleForCell() -> String {
        var title = ""
        
        switch self {
        case .sendDataOnlyViaWiFi:
            title = NSLocalizedString("SettingsVC.cellTitle.sendDataOnlyViaWiFi", comment: "")
        case .sendTracksAutomatically:
            title = NSLocalizedString("SettingsVC.cellTitle.sendTracksAutomatically", comment: "")
        case .autostartRecordRoutes:
            title = NSLocalizedString("SettingsVC.cellTitle.autostartRecordRoutes", comment: "")

        }
        return title
    }
}

enum SettingSection: Int {
    case signIn
    case switchParameters
    
    static func numberOfSections() -> Int {
        return 2
    }
    
    func numberOfRows() -> Int {
        switch self {
        case .signIn:
            return 1
        case .switchParameters:
            return SettingsParameters.numberOfRows()
        }
    }
    
    func titleForHeader() -> String? {
        switch self {
        case .signIn:
            return NSLocalizedString("SettingsVC.signInHeaderTitle", comment: "")
        default:
            return nil
        }
    }
}
