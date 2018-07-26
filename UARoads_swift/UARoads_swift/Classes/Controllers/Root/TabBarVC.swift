//
//  TabBarVC.swift
//  iseeds
//
//  Created by Victor Amelin on 1/25/17.
//  Copyright © 2017 UARoads. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        selectedIndex = 0
        
        setupInterface()
        
        AnalyticManager.sharedInstance.reportEvent(category: "System", action: "UaroadsTabBarController viewDidLoad")
    }
    
    func setupInterface() {
        let routesNVC = UINavigationController(rootViewController: RoutesVC())
        let recordNVC = UINavigationController(rootViewController: RecordTrackVC.initFromStoryboard())
        let settingsNVC = UINavigationController(rootViewController: SettingsVC())
        
        setViewControllers([routesNVC, recordNVC, settingsNVC], animated: false)
        
        let routesItem = tabBar.items?[TabbarItem.buildRoute.rawValue]
        routesItem?.title = TabbarItem.buildRoute.title()
        routesItem?.selectedImage = UIImage(named: "routes-active")
        routesItem?.image = UIImage(named: "routes-normal")
        
        let recordsItem = tabBar.items?[TabbarItem.recordTrack.rawValue]
        recordsItem?.title = TabbarItem.recordTrack.title()
        recordsItem?.selectedImage = UIImage(named: "record-active")
        recordsItem?.image = UIImage(named: "record-normal")
        
        let settingsItem = tabBar.items?[TabbarItem.settings.rawValue]
        settingsItem?.title = TabbarItem.settings.title()
        settingsItem?.selectedImage = UIImage(named: "settings-active")
        settingsItem?.image = UIImage(named: "settings-normal")
        
        //set font style
        for item in tabBar.items! {
            item.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.colorPrimaryDark], for: .selected)
            item.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.gray], for: .normal)
        }
    }
}









