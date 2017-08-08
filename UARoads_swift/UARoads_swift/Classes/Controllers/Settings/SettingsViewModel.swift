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
            footer.versionLbl.text = "Version: " + Utilities.appVersion()
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
        footer.textLbl.text = "Authorized users can view their site statistics, get in TOP, gain reward for their achievements."
        
        return footer
    }
}



enum SettingsParameters: Int {
    case sendDataOnlyViaWiFi
    case autostartRecordRoutes
    case showGraphView
    
    static func numberOfRows() -> Int {
        return 3
    }
    
    func titleForCell() -> String {
        var title = ""
        
        switch self {
        case .sendDataOnlyViaWiFi:
            title = "Send data only via WiFi"
        case .autostartRecordRoutes:
            title = "Route recording autostart"
        case .showGraphView:
            title = "Show map / graph"
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
            return "USER"
        default:
            return nil
        }
    }
}
