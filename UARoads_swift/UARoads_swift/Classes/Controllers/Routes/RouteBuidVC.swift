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
    fileprivate let fromDetailLbl = UILabel()
    fileprivate let toLbl = UILabel()
    fileprivate let toDetailLbl = UILabel()
    fileprivate let goBtn = UIButton()
    
    fileprivate var fromModel: SearchResultModel!
    fileprivate var toModel: SearchResultModel!
    private var directionsRoute: Route!
    
    init(from: SearchResultModel, to: SearchResultModel) {
        super.init()
        
        self.fromModel = from
        self.toModel = to
        
        //refactor
        let origin = Waypoint(coordinate: fromModel.locationCoordianate!, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: toModel.locationCoordianate!, coordinateAccuracy: -1, name: "Finish")
        
        let options = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
        
        _ = Directions.shared.calculate(options) { [unowned self] (waypoints, routes, error) in
            if let sRoutes = routes {
                self.directionsRoute = sRoutes.first
                self.draw(route: self.directionsRoute)
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
        view.addSubview(fromDetailLbl)
        view.addSubview(toDetailLbl)
        
        goBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50.0)
            make.width.equalToSuperview()
        }
        
        toLbl.snp.makeConstraints { (make) in
            make.left.equalTo(15.0)
            make.right.equalTo(-15.0)
            make.bottom.equalTo(goBtn.snp.top).offset(-10.0)
            make.height.equalTo(30.0)
        }
        
        toDetailLbl.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(65.0)
            make.centerY.equalTo(toLbl)
            make.right.equalTo(toLbl)
            make.height.equalTo(toLbl)
        }
        
        fromLbl.snp.makeConstraints { (make) in
            make.left.equalTo(toLbl)
            make.right.equalTo(toLbl)
            make.height.equalTo(toLbl)
            make.bottom.equalTo(toLbl.snp.top)
        }
        
        fromDetailLbl.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(65.0)
            make.height.equalTo(fromLbl)
            make.right.equalTo(fromLbl)
            make.centerY.equalTo(fromLbl)
        }
        
        routeView.snp.makeConstraints { (make) in
            make.bottom.equalTo(fromLbl.snp.top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
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
        
        fromDetailLbl.text = fromModel.locationName
        toDetailLbl.text = toModel.locationName
        
        fromDetailLbl.font = UIFont.systemFont(ofSize: 14.0)
        toDetailLbl.font = UIFont.systemFont(ofSize: 14.0)
        
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








