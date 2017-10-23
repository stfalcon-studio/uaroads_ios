//
//  Storyboard.swift
//  UARoads_swift
//
//  Created by Max Vasilevsky on 10/23/17.
//  Copyright © 2017 Max Vasilevsky. All rights reserved.
//

import UIKit

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension UIViewController : StoryboardIdentifiable { }

//protocol StoryboardInit {
//    static func initFromStoryboard<T: StoryboardIdentifiable>() -> T
//}
//
//extension StoryboardInit where Self: UIViewController {
//    static func initFromStoryboard<T: StoryboardIdentifiable>() -> T {
//        let storyboard = UIStoryboard(name:T.storyboardIdentifier, bundle: nil)
//        return storyboard.instantiateViewController() as T
//    }
//}

extension UIViewController {
    static func initFromStoryboard() -> Self {
        let describing = String(describing: self)
        let storyboard = UIStoryboard(name:describing, bundle: nil)
        return storyboard.instantiateViewController()
    }
}

extension UIStoryboard {
    
    enum Storyboard: String {
        case Main
        case Auth
    }
    
    static func initAsViewController<T: StoryboardIdentifiable>() -> T {
        let storyboard = UIStoryboard(name:T.storyboardIdentifier, bundle: nil)
        return storyboard.instantiateViewController() as T
    }
    
    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: bundle)
    }
    
    class func storyboard(storyboard: Storyboard, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: storyboard.rawValue, bundle: bundle)
    }
    
    func instantiateViewController<T: StoryboardIdentifiable>() -> T {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }
        return viewController
    }
}
