//
//  MainVCProtocol.swift
//  iseeds
//
//  Created by Victor Amelin on 1/23/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation

@objc protocol MainVCProtocol {
    @objc optional func setupConstraints()
    @objc optional func setupInterface()
    @objc optional func setupRx()
    @objc optional func updateInterface()
}
