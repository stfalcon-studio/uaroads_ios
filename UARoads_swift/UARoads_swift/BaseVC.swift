//
//  BaseVC.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/7/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import UIKit
import UIViewController_ODStatusBar
import RxSwift
import RxCocoa
import SnapKit
import Moya

class BaseVC: UIViewController {

    let disposeBag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //change status bar color
        od_setStatusBarStyle(.lightContent)
        od_updateStatusBarAppearance(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension BaseVC: MainVCProtocol {
    func setupConstraints() {
        //
    }
    
    func setupInterface() {
        //
    }
    
    func setupRx() {
        //
    }
}
