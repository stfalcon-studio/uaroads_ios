//
//  TracksVC.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 UARoads. All rights reserved.
//

import UIKit
import RealmSwift
import DZNEmptyDataSet

class TracksVC: BaseTVC {
    
    private var dataSource = RealmHelper.objects(type: TrackModel.self)
    private var notificationToken: NotificationToken? = nil
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
    }
    
    override func setupRx() {
        super.setupRx()
//        notificationToken = dataSource?.addNotificationBlock { [weak self] changes in
//            switch changes {
//            case .initial:
//                self?.tableView.reloadData()
//                break
//
//            case .update(let object, let deletions, let insertions, let modifications):
//                print("delet - \(deletions.count) ins - \(insertions.count) mod - \(modifications.count)")
//                if deletions.count > 0 && insertions.count > 0 {
//                    self?.tableView.reloadData()
//                }
//                self?.tableView.beginUpdates()
//                self?.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .left)
//                self?.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .left)
//                self?.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .none)
//                self?.tableView.endUpdates()
//                break
//            case .error(let error):
//                fatalError("ERROR: \(error)")
//                break
//            }
//        }
//
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
    }
    
    private func updateData() {
        dataSource = RealmHelper.objects(type: TrackModel.self)
        self.tableView.reloadData()
    }
    
    func removeItemAt(_ indexPath:IndexPath) {
        let item = dataSource![indexPath.row]
        item.deletePits()
        item.delete()
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .left)
        tableView.endUpdates()
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    override func setupInterface() {
        super.setupInterface()
        navigationController?.navigationBar.tintColor = .white
        title = NSLocalizedString("TracksVC.title", comment: "")
        
        tableView.register(RecordedCell.self, forCellReuseIdentifier: "RecordedCell")
        tableView.tableFooterView = UIView()        
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
            removeItemAt(indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordedCell") as! RecordedCell
        guard let item = dataSource?[indexPath.row] else {
            return cell
        }
        cell.configureFromTrack(item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

extension TracksVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let titleStr = NSLocalizedString("TracksVC.emptyDataSet.title", comment: "")
        let attrs = [NSAttributedStringKey.foregroundColor : UIColor.colorPrimaryDark,
                     NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18.0)]
        
        return NSMutableAttributedString(string: titleStr, attributes: attrs)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let btnTitle = NSLocalizedString("start", comment: "").uppercased()
        let attrs = [NSAttributedStringKey.foregroundColor:UIColor.colorAccent,
                     NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 14.0)]
        return NSMutableAttributedString(string: btnTitle, attributes: attrs)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
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



