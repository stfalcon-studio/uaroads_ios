//
//  TracksVC.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import StfalconSwiftExtensions
import RealmSwift
import DZNEmptyDataSet

class TracksVC: BaseTVC {
    fileprivate let dataSource = RealmHelper.objects(type: TrackModel.self)
    fileprivate var notificationToken: NotificationToken? = nil
    
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
        
        notificationToken = dataSource?.addNotificationBlock { [weak self] changes in
            switch changes {
            case .initial:
                self?.tableView.reloadData()
                break
                
            case .update(_, let deletions, let insertions, let modifications):
                self?.tableView.beginUpdates()
                self?.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self?.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                self?.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self?.tableView.endUpdates()
                break
            case .error(let error):
                fatalError("ERROR: \(error)")
                break
            }
        }
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
    }
    
    deinit {
        notificationToken?.stop()
    }
    
    override func setupInterface() {
        super.setupInterface()
        
        title = NSLocalizedString("Recorded tracks", comment: "title")
        
        tableView.register(RecordedCell.self, forCellReuseIdentifier: "RecordedCell")
        tableView.tableFooterView = UIView()
    }
    
    func test() {
        //
    }
}

extension TracksVC {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = dataSource![indexPath.row]
            item.delete()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordedCell") as! RecordedCell
        let item = dataSource?[indexPath.row]
        
        DateManager.sharedInstance.setFormat("dd MMMM yyyy HH:mm")
        cell.dateLbl.text = DateManager.sharedInstance.getDateFormatted(item!.date)
        cell.stateLbl.text = TrackStatus(rawValue: item!.status)?.title()
        cell.distLbl.text = NSString(format: "%.2f km", (item?.distance)!) as String
        
        return cell
    }
}

extension TracksVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSMutableAttributedString(string: NSLocalizedString("You have no tracks yet", comment: ""), attributes: [NSForegroundColorAttributeName:UIColor.gray, NSFontAttributeName:UIFont.systemFont(ofSize: 18.0)])
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        return NSMutableAttributedString(string: NSLocalizedString("start", comment: "").uppercased(), attributes: [NSForegroundColorAttributeName:UIColor.green, NSFontAttributeName:UIFont.boldSystemFont(ofSize: 14.0)])
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        (tabBarController as? TabBarVC)?.selectedIndex = 1
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldFade(in scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}

















