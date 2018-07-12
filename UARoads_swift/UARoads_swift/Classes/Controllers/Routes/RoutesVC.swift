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
import Mapbox

class RoutesVC: BaseTVC {
    
    fileprivate let toTF = LocationTextField()
    fileprivate let lineView = UIView()
    
    private lazy var mapView: MGLMapView = {
        let map: MGLMapView = MGLMapView(frame: self.view.bounds)
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //TODO: investigate default center
        map.setCenter(CLLocationCoordinate2D(latitude: 49.3864569, longitude: 31.61828032), zoomLevel: 12, animated: false)
        return map
    }()
    
    fileprivate let fromLocationBtn = UIButton()
    fileprivate let toLocationBtn = UIButton()
    fileprivate let clearBtn = UIBarButtonItem(image: UIImage(named: "reset-normal"), style: .plain, target: nil, action: nil)
    fileprivate let buildBtn = UIButton()
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate var dataSource = [SearchResultModel]()
    fileprivate var fromModel: SearchResultModel?
    fileprivate var toModel: SearchResultModel?
    
    fileprivate var currentLocation: CLLocationCoordinate2D? {
        didSet {
            if let sValue = currentLocation {
                mapView.setCenter(sValue, zoomLevel: 14, animated: true)
                fromModel = SearchResultModel(locationCoordianate: sValue, locationName: "current location", locationDescription: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
        setupInterface()
        setupRx()
        
        updateLocation()
    }
    
    func setupConstraints() {
        view.addSubview(mapView)
        view.addSubview(toTF)
        view.addSubview(buildBtn)
        
        mapView.addSubview(tableView)
        
        toTF.snp.makeConstraints { (make) in
            make.left.equalTo(15.0)
            make.right.equalTo(-15.0)
            make.top.equalTo(16)
            make.height.equalTo(50.0)
            toTF.backgroundColor = .white
            toTF.layer.cornerRadius = 10
        }
        
        buildBtn.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.top.equalTo(toTF.snp.bottom).offset(4)
            make.height.equalTo(50.0)
            make.trailing.equalTo(toTF.snp.trailing).offset(-20)
            buildBtn.layer.cornerRadius = 25
        }
        
        mapView.snp.makeConstraints { maker in
            maker.width.equalToSuperview()
            maker.top.equalTo(view.snp.top)
            maker.centerX.equalToSuperview()
            maker.bottom.equalToSuperview()
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
        
        customizeLocationButtons()
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
        
        toTF
            .rx
            .controlEvent(.editingChanged)
            .bind { [weak self] in
                self?.textFieldValueChanged(self?.toTF)
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
        
        //keyboard appearance
        RxKeyboard
            .instance
            .willShowVisibleHeight
            .drive(onNext: { [weak self] offset in
                self?.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, offset, 0.0)
                }, onCompleted: nil, onDisposed: nil)
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
    
    private func customizeToTF() {
        toTF.placeholder = NSLocalizedString("RoutesVC.toTextFieldPlaceholder", comment: "")
        toTF.autocorrectionType = .no
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
        locationManager.startUpdatingLocation()
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
            self.fromModel = SearchResultModel(locationCoordianate: coord,
                                               locationName: "current location",
                                               locationDescription: nil)
        }
        checkLocationAuthStatus()
        self.checkFields()
    }
    
    private func clearButtonTapped() {
        self.toModel = nil
        self.fromModel = nil
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
        
        if toTF.isFirstResponder {
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
        if let coord = locations.last {
            currentLocation = coord.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription)")
    }

}
