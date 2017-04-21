//
//  RoutesVC.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import RxKeyboard
import CoreLocation

class RoutesVC: BaseTVC {
    fileprivate let fromTF = UITextField()
    fileprivate let toTF = UITextField()
    fileprivate let lineView = UIView()
    fileprivate let webView = UIWebView()
    fileprivate let fromLocationBtn = UIButton()
    fileprivate let toLocationBtn = UIButton()
    fileprivate let clearBtn = UIBarButtonItem(image: UIImage(named: "reset-normal"), style: .plain, target: nil, action: nil)
    fileprivate let buildBtn = UIButton()
    
    fileprivate var dataSource = [SearchResultModel]()
    fileprivate var fromModel: SearchResultModel?
    fileprivate var toModel: SearchResultModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
        setupInterface()
        setupRx()
        
        HUDManager.sharedInstance.show(from: self)
        LocationManager.sharedInstance.manager.requestLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdate(note:)), name: NSNotification.Name.init(rawValue: Note.locationUpdate.rawValue), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupConstraints() {
        view.addSubview(fromTF)
        view.addSubview(toTF)
        view.addSubview(lineView)
        view.addSubview(webView)
        view.addSubview(buildBtn)
        
        webView.addSubview(tableView)
        
        fromTF.snp.makeConstraints { (make) in
            make.left.equalTo(15.0)
            make.right.equalTo(-15.0)
            make.top.equalToSuperview()
            make.height.equalTo(50.0)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(1.0)
            make.left.equalTo(fromTF)
            make.right.equalTo(fromTF)
            make.top.equalTo(fromTF.snp.bottom)
        }
        
        toTF.snp.makeConstraints { (make) in
            make.left.equalTo(fromTF)
            make.right.equalTo(fromTF)
            make.height.equalTo(fromTF)
            make.top.equalTo(lineView)
        }
        
        buildBtn.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalTo(toTF.snp.bottom)
            make.height.equalTo(50.0)
            make.centerX.equalToSuperview()
        }
        
        webView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalTo(toTF.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func setupInterface() {
        super.setupInterface()
        
        title = NSLocalizedString("Build route", comment: "title")
        
        lineView.backgroundColor = UIColor.lightGray
        lineView.alpha = 0.5
        
        fromLocationBtn.setImage(UIImage(named: "location"), for: .normal)
        fromLocationBtn.sizeToFit()
        
        toLocationBtn.setImage(UIImage(named: "location"), for: .normal)
        toLocationBtn.sizeToFit()
        
        fromTF.placeholder = NSLocalizedString("From", comment: "fromTF")
        fromTF.autocorrectionType = .no
        fromTF.rightView = fromLocationBtn
        fromTF.rightViewMode = .unlessEditing
        fromTF.clearButtonMode = .whileEditing
        fromTF.clearsOnBeginEditing = true
        
        toTF.placeholder = NSLocalizedString("To", comment: "toTF")
        toTF.autocorrectionType = .no
        toTF.rightView = toLocationBtn
        toTF.rightViewMode = .unlessEditing
        toTF.clearButtonMode = .whileEditing
        toTF.clearsOnBeginEditing = true
        
        buildBtn.setTitle(NSLocalizedString("Build", comment: "buildBtn"), for: .normal)
        buildBtn.titleLabel?.textColor = UIColor.white
        buildBtn.backgroundColor = UIColor.colorAccent
        
        //hidden by default
        tableView.alpha = 0.0
        checkFields()
    }
    
    override func setupRx() {
        super.setupRx()
        
        buildBtn
            .rx
            .tap
            .bind { [weak self] in
                HUDManager.sharedInstance.show(from: self!)
                UARoadsSDK.sharedInstance.checkRouteAvailability(coord1: (self?.fromModel?.locationCoordianate)!,
                                                                 coord2: (self?.toModel?.locationCoordianate)!,
                                                                 handler: { status in
                                                                    switch status {
                                                                    case 200:
                                                                        guard let from = self?.fromModel, let to = self?.toModel else { return }
                                                                        AnalyticManager.sharedInstance.reportEvent(category: "Navigation", action: "search")
                                                                        let navVC = UINavigationController(rootViewController: RouteBuidVC(from: from, to: to))
                                                                        self?.present(navVC, animated: true, completion: nil)
                                                                        
                                                                    case 404:
                                                                        self?.showAlert(title: NSLocalizedString("Error", comment: ""), text: NSLocalizedString("Server connection error", comment: ""), controller: self, handler: nil)
                                                                        
                                                                    case 207:
                                                                        self?.showAlert(title: NSLocalizedString("Error", comment: ""), text: NSLocalizedString("Cannot find route between points", comment: ""), controller: self, handler: nil)
                                                                        
                                                                    default: break
                                                                    }
                                                                    HUDManager.sharedInstance.hide()
                })
            }
            .addDisposableTo(disposeBag)
        
        tableView
            .rx
            .itemSelected
            .bind { [weak self] ip in
                if let strongSelf = self {
                    let selectedItem = strongSelf.dataSource[ip.row]
                    if strongSelf.fromTF.isFirstResponder {
                        strongSelf.fromModel = selectedItem
                        strongSelf.fromTF.text = strongSelf.fromModel?.locationName
                        
                    } else if strongSelf.toTF.isFirstResponder {
                        strongSelf.toModel = selectedItem
                        strongSelf.toTF.text = strongSelf.toModel?.locationName
                    }
                    strongSelf.checkFields()
                    strongSelf.hideTableView()
                }
            }
            .addDisposableTo(disposeBag)
        
        clearBtn
            .rx
            .tap
            .bind { [weak self] in
                self?.toModel = nil
                self?.fromModel = nil
                self?.fromTF.text = ""
                self?.toTF.text = ""
                self?.dataSource = []
                self?.tableView.reloadData()
                self?.view.endEditing(true)
                self?.navigationItem.rightBarButtonItem = nil
                self?.hideTableView()
            }
            .addDisposableTo(disposeBag)
        
        //location taped
        fromLocationBtn
            .rx
            .tap
            .bind { [weak self] in
                LocationManager.sharedInstance.manager.requestLocation()
                if let coord = LocationManager.sharedInstance.manager.location?.coordinate {
                    self?.fromTF.text = NSLocalizedString("My current location", comment: "myLocation")
                    self?.fromTF.resignFirstResponder()
                    self?.fromModel = SearchResultModel(locationCoordianate: coord, locationName: self?.fromTF.text, locationDescription: nil)
                }
                self?.checkFields()
            }
            .addDisposableTo(disposeBag)
        
        toLocationBtn
            .rx
            .tap
            .bind { [weak self] in
                LocationManager.sharedInstance.manager.requestLocation()
                if let coord = LocationManager.sharedInstance.manager.location?.coordinate {
                    self?.toTF.text = NSLocalizedString("My current location", comment: "myLocation")
                    self?.toTF.resignFirstResponder()
                    self?.toModel = SearchResultModel(locationCoordianate: coord, locationName: self?.toTF.text, locationDescription: nil)
                }
                self?.checkFields()
            }
            .addDisposableTo(disposeBag)
        
        //change values
        fromTF
            .rx
            .controlEvent(.editingChanged)
            .bind { [weak self] in
                if self?.navigationItem.rightBarButtonItem == nil {
                    self?.navigationItem.rightBarButtonItem = self?.clearBtn
                }
                if let text = self?.fromTF.text {
                    NetworkManager.sharedInstance.searchResults(location: text, handler: { results in
                        self?.dataSource = results
                        self?.tableView.reloadData()
                        self?.showTableView()
                    })
                }
            }
            .addDisposableTo(disposeBag)
        
        toTF
            .rx
            .controlEvent(.editingChanged)
            .bind { [weak self] in
                if self?.navigationItem.rightBarButtonItem == nil {
                    self?.navigationItem.rightBarButtonItem = self?.clearBtn
                }
                if let text = self?.toTF.text {
                    NetworkManager.sharedInstance.searchResults(location: text, handler: { results in
                        self?.dataSource = results
                        self?.tableView.reloadData()
                        self?.showTableView()
                    })
                }
            }
            .addDisposableTo(disposeBag)
        
        //all touches
        fromTF
            .rx
            .controlEvent(.editingDidBegin)
            .bind { [weak self] in
                UIView.animate(withDuration: 0.2, animations: {
                    self?.buildBtn.alpha = 0.0
                })
            }
            .addDisposableTo(disposeBag)
        
        toTF
            .rx
            .controlEvent(.editingDidBegin)
            .bind { [weak self] in
                UIView.animate(withDuration: 0.2, animations: {
                    self?.buildBtn.alpha = 0.0
                })
            }
            .addDisposableTo(disposeBag)
        
        //end editing (enter clicked)
        toTF
            .rx
            .controlEvent(.editingDidEndOnExit)
            .bind { [weak self] in
                self?.hideTableView()
                self?.checkFields()
            }
            .addDisposableTo(disposeBag)
        
        fromTF
            .rx
            .controlEvent(.editingDidEndOnExit)
            .bind { [weak self] in
                self?.hideTableView()
                self?.checkFields()
            }
            .addDisposableTo(disposeBag)
        
        //keyboard appearance
        RxKeyboard.instance.willShowVisibleHeight
            .drive(onNext: { [weak self] offset in
                self?.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, offset, 0.0)
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        //webview
        webView
            .rx
            .didFinishLoad
            .bind {
                HUDManager.sharedInstance.hide()
            }
            .addDisposableTo(disposeBag)
    }
    
    //MARK: Helpers
    fileprivate func showTableView() {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.tableView.alpha = 1.0
        })
    }
    
    fileprivate func hideTableView() {
        view.endEditing(true)
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.tableView.alpha = 0.0
        })
    }
    
    fileprivate func checkFields() {
        if fromModel != nil && toModel != nil {
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.buildBtn.alpha = 1.0
            })
        } else {
            buildBtn.alpha = 0.0
        }
    }
    
    //MARK: Actions
    @objc fileprivate func locationUpdate(note: NSNotification) {
        var urlStr: String!
        if let coord = (note.object as? [CLLocation])?.last {
            urlStr = "http://uaroads.com/static-map?mob=true&lat=\(coord.coordinate.latitude)&lon=\(coord.coordinate.longitude)&zoom=14"
        } else {
            urlStr = "http://uaroads.com/static-map?mob=true&lat=49.3864569&lon=31.6182803&zoom=6"
        }
        webView.loadRequest(URLRequest(url: URL(string: urlStr)!))
    }
}

extension RoutesVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var searchCell: UITableViewCell!
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
            searchCell = cell
        } else {
            searchCell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        let item = dataSource[indexPath.row]
        
        searchCell.detailTextLabel?.text = item.locationDescription
        searchCell.textLabel?.text = item.locationName
        
        return searchCell
    }
}











