//
//  BaseTVC.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/10/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

class BaseTVC: BaseVC {
    var tableView = UITableView()
    
    func setupInterface() {
        tableView.estimatedRowHeight = 50.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setupRx() {
        tableView
            .rx
            .setDelegate(self)
            .addDisposableTo(disposeBag)
        
        tableView
            .rx
            .setDataSource(self)
            .addDisposableTo(disposeBag)
    }
}

extension BaseTVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("don`t use this method directly!")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("don`t use this method directly!")
    }
}
