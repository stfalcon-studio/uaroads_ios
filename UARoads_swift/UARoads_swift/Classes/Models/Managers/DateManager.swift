//
//  DateManager.swift
//  UARoads_swift
//
//  Created by Victor Amelin on 4/11/17.
//  Copyright © 2017 Victor Amelin. All rights reserved.
//

import Foundation

final class DateManager {
    private init() {
        dateFormatter.dateStyle = .long
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.current
    }
    static let sharedInstance = DateManager()
    
    private let dateFormatter = DateFormatter()
    
    func setFormat(_ format: String) {
        dateFormatter.dateFormat = format
    }
    
    func getDateFormatted(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}
