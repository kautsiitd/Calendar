//
//  Date.swift
//  Calendar
//
//  Created by Kautsya Kanu on 16/11/17.
//  Copyright © 2017 Kautsya Kanu. All rights reserved.
//

import Foundation

extension Date {
    func convertTo(string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = string
        let strMonth = dateFormatter.string(from: self)
        return strMonth
    }
    func uniqueId() -> String {
        return convertTo(string: "MMM d,yyyy")
    }
}
