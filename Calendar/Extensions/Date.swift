//
//  Date.swift
//  Calendar
//
//  Created by Kautsya Kanu on 16/11/17.
//  Copyright © 2017 Kautsya Kanu. All rights reserved.
//

import Foundation

extension Date {
    func get(component: Calendar.Component) -> Int {
        return Calendar.current.component(component, from: self)
    }
    
    func numberOfWeeks() -> Int {
        return Calendar.current.range(of: .weekOfMonth, in: .month, for: self)!.upperBound - 1
    }
    
    func firstDateOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.month, .year], from: self)
        return Calendar.current.date(from: components)!
    }
    
    func isWeekend() -> Bool {
        let weekday = get(component: .weekday)
        return (weekday == 1 || weekday == 7)
    }
    
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func convertTo(string: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = string
        let strMonth = dateFormatter.string(from: self)
        return strMonth
    }
    
    func uniqueId() -> String {
        return convertTo(string: "MMM d, yyyy")
    }
}
