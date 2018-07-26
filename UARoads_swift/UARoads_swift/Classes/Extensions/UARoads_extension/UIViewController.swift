//
//  ViewController.swift
//
//  Created by Victor Amelin on 1/31/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

public extension UIViewController {
    public func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
    
    class var storyboardIdentifier: String {
        return String(describing: self)
    }
}







