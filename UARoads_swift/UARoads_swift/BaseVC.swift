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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Helpers
    func showAlert(title: String? = "", text: String, controller: UIViewController? = nil, handler: EmptyHandler?) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        if let handler = handler {
            let handlerAction = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                handler()
            })
            alert.addAction(handlerAction)
        } else {
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
        }
        if let vc = controller {
            vc.present(alert, animated: true, completion: nil)
        } else {
            topViewController()?.present(alert, animated: true, completion: nil)
        }
    }
}





