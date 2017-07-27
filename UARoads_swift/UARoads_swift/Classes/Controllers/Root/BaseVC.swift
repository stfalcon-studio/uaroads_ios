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

class BaseVC: UIViewController, MainVCProtocol {

    let disposeBag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //change status bar color
        od_setStatusBarStyle(.lightContent)
        od_updateStatusBarAppearance(animated: true)
    }
    
}





