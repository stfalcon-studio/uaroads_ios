//
//  TabBarVC.swift
//  iseeds
//
//  Created by Victor Amelin on 1/25/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
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
        let recordNVC = UINavigationController(rootViewController: RecordVC())
        let tracksNVC = UINavigationController(rootViewController: TracksVC())
        let settingsNVC = UINavigationController(rootViewController: SettingsVC())
        
        setViewControllers([routesNVC, recordNVC, tracksNVC, settingsNVC], animated: false)
        
        let routesItem = tabBar.items?[0]
        routesItem?.title = NSLocalizedString("Routes", comment: "routesItem")
        routesItem?.selectedImage = UIImage(named: "routes-active")
        routesItem?.image = UIImage(named: "routes-normal")
        
        let recordsItem = tabBar.items?[1]
        recordsItem?.title = NSLocalizedString("Record", comment: "recordsItem")
        recordsItem?.selectedImage = UIImage(named: "record-active")
        recordsItem?.image = UIImage(named: "record-normal")
        
        let tracksItem = tabBar.items?[2]
        tracksItem?.title = NSLocalizedString("Tracks", comment: "tracksItem")
        tracksItem?.selectedImage = UIImage(named: "tracks-active")
        tracksItem?.image = UIImage(named: "tracks-normal")
        
        let settingsItem = tabBar.items?[3]
        settingsItem?.title = NSLocalizedString("Settings", comment: "settingsItem")
        settingsItem?.selectedImage = UIImage(named: "settings-active")
        settingsItem?.image = UIImage(named: "settings-normal")
        
        //set font style
        for item in tabBar.items! {
            item.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.colorPrimaryDark], for: .selected)
            item.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.gray], for: .normal)
        }
    }
}









