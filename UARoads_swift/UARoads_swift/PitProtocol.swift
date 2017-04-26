//
//  PitProtocol.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/26/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation

protocol PitProtocol {
    var latitude: Double { get set}
    var longitude: Double { get set}
    var time: String { get set}
    var value: Double { get set}
    var tag: String { get set}
}
