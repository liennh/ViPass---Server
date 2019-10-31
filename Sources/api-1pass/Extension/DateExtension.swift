//
//  DateExtension.swift
//  1Pass
//
//  Created by Ngo Lien on 6/9/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation

extension Date {
    func utcString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = AppConfig.DateTimeFormat
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: self)
    }
}
