//
//  HUDManaged.swift
//  ACT_ios
//
//  Created by Victor Amelin on 9/6/16.
//  Copyright © 2016 Victor Amelin. All rights reserved.
//

import Foundation
import JGProgressHUD

final class HUDManager {
    private init() {}
    static let sharedInstance = HUDManager()
    
    fileprivate var HUD: JGProgressHUD = {
        let hud = JGProgressHUD(style: JGProgressHUDStyle.extraLight)!
        hud.interactionType = .blockAllTouches
        hud.position = .center
        
        return hud
    }()
    
    func show(from: UIViewController) {
        DispatchQueue.main.async { [weak self] _ in
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self?.HUD.show(in: from.view)
        }
    }
    
    func hide() {
        DispatchQueue.main.async { [weak self] in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self?.HUD.dismiss(animated: true)
        }
    }
}














