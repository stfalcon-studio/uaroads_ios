//
//  GetAddedImages.swift
//  DOITTest
//
//  Created by Max Vasilevsky on 9/20/17.
//  Copyright © 2017 Max Vasilevsky. All rights reserved.
//

import UIKit
import Alamofire

class StatisticRequest: BaseRequest {
    var email = ""
    var uid = ""
    
    override func apiPath() -> String {
        return "/statistic"
    }
    
    override func parameters() -> [String : Any] {
        return  ["user":email,
                 "uid":uid]
    }
    
    
}
