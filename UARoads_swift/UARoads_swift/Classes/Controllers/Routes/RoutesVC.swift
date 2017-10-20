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
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate var dataSource = [SearchResultModel]()
    fileprivate var fromModel: SearchResultModel?
    fileprivate var toModel: SearchResultModel?
    
    fileprivate var currentLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
        setupInterface()
        setupRx()
        
        updateLocation()
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
        
        title = NSLocalizedString("RoutesVC.title", comment: "")
        
        lineView.backgroundColor = UIColor.lightGray
        lineView.alpha = 0.5
        
        clearBtn.tintColor = UIColor.white
        
        webView.scalesPageToFit = true
        
        customizeLocationButtons()
        customizeFromTF()
        customizeToTF()
        customizeBuildButton()
        
        //hidden by default
        tableView.alpha = 0.0
        checkFields()
        
        if let tabbar: UITabBar = self.tabBarController?.tabBar {
            guard let routeItem: UITabBarItem = tabbar.items?[TabbarItem.buildRoute.rawValue] else { return }
            routeItem.title = TabbarItem.buildRoute.title()
        }
    }
    
    override func setupRx() {
        super.setupRx()
        
        buildBtn
            .rx
            .tap
            .bind { [weak self] in
                self?.buildRouteTapped()
            }
            .addDisposableTo(disposeBag)
        
        tableView
            .rx
            .itemSelected
            .bind { [weak self] indexPath in
                self?.tableviewDidSelectItem(at: indexPath)
            }
            .addDisposableTo(disposeBag)
        
        clearBtn
            .rx
            .tap
            .bind { [weak self] in
                self?.clearButtonTapped()
            }
            .addDisposableTo(disposeBag)
        
        //location taped
        fromLocationBtn
            .rx
            .tap
            .bind { [weak self] in
                self?.fromLocationTapped()
            }
            .addDisposableTo(disposeBag)
        
        toLocationBtn
            .rx
            .tap
            .bind { [weak self] in
                self?.toLocationTapped()
            }
            .addDisposableTo(disposeBag)
        
        //change values
        fromTF
            .rx
            .controlEvent(.editingChanged)
            .bind { [weak self] in
                self?.textFieldValueChanged(self?.fromTF)
            }
            .addDisposableTo(disposeBag)
        
        toTF
            .rx
            .controlEvent(.editingChanged)
            .bind { [weak self] in
                self?.textFieldValueChanged(self?.toTF)
            }
            .addDisposableTo(disposeBag)
        
        //all touches
        fromTF
            .rx
            .controlEvent(.editingDidBegin)
            .bind { [weak self] in
                self?.hideBuildButton()
            }
            .addDisposableTo(disposeBag)
        
        toTF
            .rx
            .controlEvent(.editingDidBegin)
            .bind { [weak self] in
                self?.hideBuildButton()
            }
            .addDisposableTo(disposeBag)
        
        //end editing (enter clicked)
        toTF
            .rx
            .controlEvent(.editingDidEndOnExit)
            .bind { [weak self] in
                self?.textFieldDidEndEditing()
            }
            .addDisposableTo(disposeBag)
        
        fromTF
            .rx
            .controlEvent(.editingDidEndOnExit)
            .bind { [weak self] in
                self?.textFieldDidEndEditing()
            }
            .addDisposableTo(disposeBag)
        
        //keyboard appearance
        RxKeyboard
            .instance
            .willShowVisibleHeight
            .drive(onNext: { [weak self] offset in
                self?.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, offset, 0.0)
                }, onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)
        
        //webview
        webView
            .rx
            .didFinishLoad
            .bind {
                
            }
            .addDisposableTo(disposeBag)
    }
    
    
    //MARK: Private funcs
    
    private func customizeLocationButtons() {
        fromLocationBtn.setImage(UIImage(named: "location"), for: .normal)
        fromLocationBtn.sizeToFit()
        
        toLocationBtn.setImage(UIImage(named: "location"), for: .normal)
        toLocationBtn.sizeToFit()
    }
    
    private func customizeBuildButton() {
        let  buttonTitle = NSLocalizedString("RoutesVC.buildButtonTitle", comment: "")
        buildBtn.setTitle(buttonTitle, for: .normal)
        buildBtn.titleLabel?.textColor = UIColor.white
        buildBtn.backgroundColor = UIColor.colorAccent
    }
    
    private func customizeFromTF() {
        fromTF.placeholder = NSLocalizedString("RoutesVC.fromTextFieldPlaceholder", comment: "")
        fromTF.autocorrectionType = .no
        fromTF.rightView = fromLocationBtn
        fromTF.rightViewMode = .unlessEditing
        fromTF.clearButtonMode = .whileEditing
        fromTF.clearsOnBeginEditing = true
    }
    
    private func customizeToTF() {
        toTF.placeholder = NSLocalizedString("RoutesVC.toTextFieldPlaceholder", comment: "")
        toTF.autocorrectionType = .no
        toTF.rightView = toLocationBtn
        toTF.rightViewMode = .unlessEditing
        toTF.clearButtonMode = .whileEditing
        toTF.clearsOnBeginEditing = true
    }
    
    private func textFieldDidEndEditing() {
        hideTableView()
        checkFields()
    }
    
    private func hideBuildButton() {
        UIView.animate(withDuration: 0.2, animations: {
            self.buildBtn.alpha = 0.0
        })
    }
    
    private func textFieldValueChanged(_ textField: UITextField?) {
        guard let tf = textField else { return }
        if navigationItem.rightBarButtonItem == nil {
            navigationItem.rightBarButtonItem = clearBtn
        }
        checkLocationAuthStatus()
        if let text = tf.text, let coordinates = locationManager.location?.coordinate {
            NetworkManager.sharedInstance.searchResults(location: text,
                                                        coord: coordinates,
                                                        handler: { [weak self] (results) in
                                                            self?.dataSource = results
                                                            self?.tableView.reloadData()
                                                            self?.showTableView()
            })
        }
    }
    
    private func toLocationTapped() {
        if let coord = self.currentLocation {
            self.toTF.text = NSLocalizedString("RoutesVC.myCurrentLocation", comment: "")
            self.toTF.resignFirstResponder()
            self.toModel = SearchResultModel(locationCoordianate: coord,
                                             locationName: self.toTF.text,
                                             locationDescription: nil)
        }
        checkLocationAuthStatus()
        self.checkFields()
    }
    
    private func fromLocationTapped() {
        if let coord = self.currentLocation {
            self.fromTF.text = NSLocalizedString("RoutesVC.myCurrentLocation", comment: "")
            self.fromTF.resignFirstResponder()
            self.fromModel = SearchResultModel(locationCoordianate: coord,
                                               locationName: self.fromTF.text,
                                               locationDescription: nil)
        }
        checkLocationAuthStatus()
        self.checkFields()
    }
    
    private func clearButtonTapped() {
        self.toModel = nil
        self.fromModel = nil
        self.fromTF.text = ""
        self.toTF.text = ""
        self.dataSource = []
        self.tableView.reloadData()
        self.view.endEditing(true)
        self.navigationItem.rightBarButtonItem = nil
        self.hideTableView()
        self.checkFields()
    }
    
    private func tableviewDidSelectItem(at indexPath: IndexPath) {
        let selectedItem = dataSource[indexPath.row]
        if fromTF.isFirstResponder {
            fromModel = selectedItem
            fromTF.text = fromModel?.locationName
            
        } else if toTF.isFirstResponder {
            toModel = selectedItem
            toTF.text = toModel?.locationName
        }
        checkFields()
        hideTableView()
    }
    
    private func buildRouteTapped() {
        guard let fromLocation = fromModel?.locationCoordianate,
            let toLocation = toModel?.locationCoordianate else { return }
        
        let distance = CLLocation.distance(from: fromLocation, to: toLocation)
        if Int(distance) < routeDistanceMin {
            AlertManager.showAlertRoutIsTooShort(currentDistance: Int(distance), viewController: self)
            return
        }
        
        NetworkManager.sharedInstance.checkRouteAvailability(coord1: fromLocation,
                                                             coord2: toLocation,
                                                             handler: { [weak self] status in
                                                                self?.handleRouteAbilityResponse(status: status)
        })
    }
    
    private func handleRouteAbilityResponse(status: Int) {
        switch status {
        case 200, 0:
            guard let from = fromModel, let to = toModel else { return }
            AnalyticManager.sharedInstance.reportEvent(category: "Navigation", action: "search")
            let navVC = UINavigationController(rootViewController: RouteBuidVC(from: from, to: to))
            present(navVC, animated: true, completion: nil)
            
        case 404:
            AlertManager.showAlertServerConnectionError(viewController: self)
            
        case 207:
            AlertManager.showAlertRouteNotFound(viewController: self)
            
        default:
            break
        }
    }
    
    fileprivate func updateLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.activityType = .automotiveNavigation
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
    }
    
    fileprivate func checkLocationAuthStatus() {
        if [.notDetermined, .restricted, .denied].contains(CLLocationManager.authorizationStatus()) {
            self.showAlertToSettings("", msg: "RoutesVC.goToLocationSetting".localized)
        }
    }
    
    fileprivate func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
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
}

extension RoutesVC : AlertToSettingsRenderer {}

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

extension RoutesVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var urlStr: String!
        if let coord = locations.last {
            currentLocation = coord.coordinate
            urlStr = "http://uaroads.com/static-map?mob=true&lat=\(coord.coordinate.latitude)&lon=\(coord.coordinate.longitude)&zoom=14"
            stopUpdatingLocation()
        } else {
            urlStr = "http://uaroads.com/static-map?mob=true&lat=49.3864569&lon=31.6182803&zoom=6"
        }
        webView.loadRequest(URLRequest(url: URL(string: urlStr)!))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let urlStr = "http://uaroads.com/static-map?mob=true&lat=49.3864569&lon=31.6182803&zoom=6"
        webView.loadRequest(URLRequest(url: URL(string: urlStr)!))
        print("ERROR: \(error.localizedDescription)")
    }
}



