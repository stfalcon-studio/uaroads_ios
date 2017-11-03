//
//  AlertManager.swift
//  UARoads_swift
//
//  Created by Roman Rybachenko on 7/4/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation

class AlertManager {
    
    // MARK: Class funcs
    class func showAlertServerConnectionError(viewController: UIViewController?) {
        let messageStr = "Alert.serverConnectionError".localized
        let titleStr = "Error".localized
        AlertManager.showAlert(title: titleStr, message: messageStr, controller: viewController, handler: nil)
    }
    
    class func showAlertRouteNotFound(viewController: UIViewController?) {
        let titleStr = "Error".localized
        let messageStr = "Alert.cannotFindRoute".localized
        AlertManager.showAlert(title: titleStr, message: messageStr, controller: viewController, handler: nil)
    }
    
    class func showAlertRoutIsTooShort(currentDistance: Int, viewController: UIViewController?) {
        let titleStr = "Warning".localized + "!"
        let messageStr = "Route distance - \(currentDistance). You can not build the route between locations where distance is less \(routeDistanceMin) meters."
        AlertManager.showAlert(title: titleStr, message: messageStr, controller: viewController, handler: nil)
    }
    
    class func showAlertCheckEmail(viewController: UIViewController?) {
        AlertManager.showAlert(message: "Alert.checkEmail".localized, controller: viewController)
    }
    
    class func showAlertRegisterDevieceError(viewController: UIViewController?) {
        AlertManager.showAlert(message: "Alert.deviceRegisterError".localized, controller: viewController)
    }
    
    class func showAlertBgRefreshDisabled(viewController: UIViewController?) {
        let messageStr = "Alert.enableBackgroundLocation".localized
        let titleStr = "Alert.enableBackgroundLocationTitle".localized
        AlertManager.showAlert(title: titleStr, message: messageStr, controller: viewController, handler: nil)
    }
    
    class func showAlertAutostartIsNotEnable(viewController: UIViewController, handler: EmptyHandler? = nil) {
        let titleStr = "Warning".localized + "!"
        let messageStr = "Alert.autostart".localized
        AlertManager.showAlert(title: titleStr, message: messageStr, controller: viewController, handler: handler)
    }
    
    class func showAlertUidCopied(viewController: UIViewController) {
        let titleStr = "Alert.uidCopied".localized
        AlertManager.showAlert(title: titleStr, message: "", controller: viewController, handler: nil)
    }
    
    
    // MARK: Private funcs
    private class func showAlert(title: String? = "", message: String, controller: UIViewController?, handler: EmptyHandler? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let handler = handler {
            let handlerAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                handler()
            })
            alert.addAction(handlerAction)
        } else {
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
        }
        controller?.present(alert, animated: true, completion: nil)
    }
    
    
}
