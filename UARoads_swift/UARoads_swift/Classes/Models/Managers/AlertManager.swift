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
        let messageStr = NSLocalizedString("Server connection error", comment: "")
        let titleStr = NSLocalizedString("Error", comment: "")
        AlertManager.showAlert(title: titleStr, message: messageStr, controller: viewController, handler: nil)
    }
    
    class func showAlertRouteNotFound(viewController: UIViewController?) {
        let titleStr = NSLocalizedString("Error", comment: "")
        let messageStr = NSLocalizedString("Cannot find route between points", comment: "")
        AlertManager.showAlert(title: titleStr, message: messageStr, controller: viewController, handler: nil)
    }
    
    class func showAlertRoutIsTooShort(currentDistance: Int, viewController: UIViewController?) {
        let titleStr = "Warning!"
        let messageStr = "Route distance - \(currentDistance). You can not build the route between locations where distance is less \(routeDistanceMin) meters."
        AlertManager.showAlert(title: titleStr, message: messageStr, controller: viewController, handler: nil)
    }
    
    class func showAlertCheckEmail(viewController: UIViewController?) {
        AlertManager.showAlert(message: "Check your email", controller: viewController)
    }
    
    class func showAlertRegisterDevieceError(viewController: UIViewController?) {
        AlertManager.showAlert(message: "Device Registration error!", controller: viewController)
    }
    
    class func showAlertBgRefreshDisabled(viewController: UIViewController?) {
        let messageStr = "You need to enable background location updates"
        let titleStr = "Background Refresh Disabled"
        AlertManager.showAlert(title: titleStr, message: messageStr, controller: viewController, handler: nil)
    }
    
    class func showAlertAutostartIsNotEnable(viewController: UIViewController, handler: EmptyHandler? = nil) {
        let titleStr = "Warning!"
        let messageStr = "Autostart isn't enable on your device"
        AlertManager.showAlert(title: titleStr, message: messageStr, controller: viewController, handler: handler)
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
