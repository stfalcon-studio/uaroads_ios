//
//  NavigatorVC.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/10/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

class NavigatorVC: BaseVC {
    fileprivate let closeBtn = UIBarButtonItem(image: UIImage(named: "reset-normal"), style: .plain, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupConstraints()
        setupInterface()
        setupRx()
    }
    
    func setupConstraints() {
        //
    }
    
    func setupInterface() {
        navigationItem.leftBarButtonItem = closeBtn
    }
    
    func setupRx() {
        closeBtn
            .rx
            .tap
            .bindNext { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
            .addDisposableTo(disposeBag)
    }
}









