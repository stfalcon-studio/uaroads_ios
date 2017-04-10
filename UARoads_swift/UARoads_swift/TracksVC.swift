//
//  TracksVC.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit

class TracksVC: BaseTVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
        setupInterface()
        setupRx()
    }
    
    func setupConstraints() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func setupRx() {
        super.setupRx()
    }
    
    override func setupInterface() {
        super.setupInterface()
        
        title = NSLocalizedString("Recorded tracks", comment: "title")
        
        tableView.register(RecordedCell.self, forCellReuseIdentifier: "RecordedCell")
    }
}

extension TracksVC {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordedCell") as! RecordedCell
        
        cell.dateLbl.text = "10 april 2017 13:11"
        cell.stateLbl.text = "Uploaded" //TODO: should be enum
        cell.distLbl.text = "0.9 km"
        
        return cell
    }
}





