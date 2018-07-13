//
//  RouteBuidVC.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation

class RouteBuidVC: BaseVC {
    private lazy var cancelBtn: UIBarButtonItem = {
        let btnTitle = NSLocalizedString("RouteBuidVC.cancelButtonTitle", comment: "")
        let cancelButton = UIBarButtonItem(title: btnTitle,
                                           style: .plain,
                                           target: nil,
                                           action: nil)
        return cancelButton
    }()

    private lazy var routeView: NavigationMapView = {
        let map = NavigationMapView(frame: self.view.bounds)
        
        
        map.delegate = self
        
        map.showsUserLocation = true
        map.setUserTrackingMode(.follow, animated: true)
        
        return map
    }()
    fileprivate let fromLbl = UILabel()
    fileprivate let toLbl = UILabel()
    fileprivate let goBtn = UIButton()
    
    private let originTextField: LocationTextField = LocationTextField()
    private let destinationTextField: LocationTextField = LocationTextField()
    
    fileprivate var fromModel: SearchResultModel!
    fileprivate var toModel: SearchResultModel!
    private var directionsRoute: Route!
    
    init(from: SearchResultModel, to: SearchResultModel) {
        super.init()
        
        self.fromModel = from
        self.toModel = to
        
        originTextField.delegate = self
        destinationTextField.delegate = self
        
        //refactor
        RouteBuildHelper.route(from: from.locationCoordianate!, to: to.locationCoordianate!) { [weak self] route in
            if let sRoute = route, let sSelf = self {
                sSelf.directionsRoute = sRoute
                sSelf.draw(route: sSelf.directionsRoute)
            } else {
                fatalError("Invalid route")
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupConstraints()
        setupInterface()
        setupRx()
    }
    
    func setupConstraints() {
        view.addSubview(routeView)
        view.addSubview(fromLbl)
        view.addSubview(toLbl)
        view.addSubview(goBtn)
        view.addSubview(originTextField)
        view.addSubview(destinationTextField)
        
        goBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50.0)
            make.width.equalToSuperview()
        }
        
        fromLbl.snp.makeConstraints { (make) in
            make.left.equalTo(15.0)
            make.height.equalTo(toLbl)
            make.top.equalToSuperview().offset(8)
            make.width.equalTo(40)
        }
        
        originTextField.snp.makeConstraints { maker in
            maker.leading.equalTo(fromLbl.snp.trailing).offset(8)
            maker.height.equalTo(fromLbl.snp.height).offset(8)
            maker.centerY.equalTo(fromLbl.snp.centerY)
            maker.trailing.equalToSuperview().offset(-12)
        }
        
        toLbl.snp.makeConstraints { (make) in
            make.left.equalTo(15.0)
            make.top.equalTo(fromLbl.snp.bottom).offset(16)
            make.height.equalTo(30.0)
            make.width.equalTo(40)
        }
        
        destinationTextField.snp.makeConstraints { maker in
            maker.leading.equalTo(toLbl.snp.trailing).offset(8)
            maker.height.equalTo(toLbl.snp.height).offset(8)
            maker.centerY.equalTo(toLbl.snp.centerY)
            maker.trailing.equalToSuperview().offset(-12)
        }
        
        routeView.snp.makeConstraints { (make) in
            make.bottom.equalTo(goBtn.snp.top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(destinationTextField.snp.bottom).offset(4)
        }
        
    }
    
    func setupInterface() {
        title = NSLocalizedString("RouteBuidVC.title", comment: "title")
        
        cancelBtn.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = cancelBtn
        
        fromLbl.text = NSLocalizedString("RouteBuidVC.fromLabel", comment: "") + " "
        toLbl.text = NSLocalizedString("RouteBuidVC.toLabel", comment: "") + " "
        
        fromLbl.textColor = UIColor.lightGray
        toLbl.textColor = UIColor.lightGray
        
        fromLbl.font = UIFont.systemFont(ofSize: 14.0)
        toLbl.font = UIFont.systemFont(ofSize: 14.0)
        
        originTextField.text = fromModel.locationName
        destinationTextField.text = toModel.locationName
        
        originTextField.font = UIFont.systemFont(ofSize: 14.0)
        destinationTextField.font = UIFont.systemFont(ofSize: 14.0)
        
        originTextField.layer.borderWidth = 0.3
        destinationTextField.layer.borderWidth = 0.3
        
        originTextField.layer.cornerRadius = 10
        destinationTextField.layer.cornerRadius = 10
        
        let goBtnTitle = NSLocalizedString("RouteBuidVC.goButtonTitle", comment: "").uppercased()
        goBtn.setTitle(goBtnTitle, for: .normal)
        goBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        goBtn.backgroundColor = UIColor.colorAccent
    }
    
    func setupRx() {
        cancelBtn
            .rx
            .tap
            .bind { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
            .addDisposableTo(disposeBag)
        
        goBtn
            .rx
            .tap
            .bind { [weak self] in
                self?.startNavigation()
            }
            .addDisposableTo(disposeBag)
    }
    
    private func calculateRoute(from origin: CLLocationCoordinate2D,
                                to destination: CLLocationCoordinate2D,
                                completion: @escaping (Route?, Error?) -> ()) {
        
        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
        
        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
        
        _ = Directions.shared.calculate(options) { [unowned self] (waypoints, routes, error) in
            if let sRoutes = routes {
                self.directionsRoute = sRoutes.first
                self.draw(route: self.directionsRoute)
            }
        }
    }
    
    private func draw(route: Route) {
        guard route.coordinateCount > 0 else { return }
        
        var routeCoordinates = route.coordinates!
        let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
        
        if let source = routeView.style?.source(withIdentifier: "route-source-1") as? MGLShapeSource {
            source.shape = polyline
        } else {
            let source = MGLShapeSource(identifier: "route-source-1", features: [polyline], options: nil)
            
            let lineStyle = MGLLineStyleLayer(identifier: "route-style-1", source: source)
            lineStyle.lineColor = NSExpression(forConstantValue: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1))
            lineStyle.lineWidth = NSExpression(forConstantValue: 3)
            
            routeView.style?.addSource(source)
            routeView.style?.addLayer(lineStyle)
        }
    }
    
    private func startNavigation() {
        let navigationViewController = NavigationViewController(for: directionsRoute)
        present(navigationViewController, animated: true, completion: nil)
    }

}

extension RouteBuidVC: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
}

extension RouteBuidVC: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == originTextField {
            print("orig")
        } else {
            print("dest")
        }
        return false
    }
    
}








