//
//  AlertRenderer.swift
//  UARoads_swift
//
//  Created by Max Vasilevsky on 10/19/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

protocol AlertRenderer {
    func displayMessage(_ title: String, msg: String)
    func displayError(_ error: Error)
}

extension AlertRenderer where Self: UIViewController {
    func displayError(_ error: Error) {
        displayMessage("Error!", msg: error.localizedDescription)
    }
    
    func displayMessage(_ title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel) { (action) -> Void in
            alertController.dismiss(animated: true, completion:nil)
        }
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
}

protocol AlertToSettingsRenderer {
    func showAlertToSettings(_ title: String, msg: String)
}

extension AlertToSettingsRenderer where Self: UIViewController {
    func showAlertToSettings(_ title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        let goSettings = UIAlertAction(title: "Settings".localized, style: .default) { (action) in
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!, completionHandler: nil)
        }
        alertController.addAction(action)
        alertController.addAction(goSettings)
        present(alertController, animated: true, completion: nil)
    }
}
