//
//  Date.swift
//  Calendar
//
//  Created by Kautsya Kanu on 16/11/17.
//  Copyright © 2017 Kautsya Kanu. All rights reserved.
//

import Foundation

extension Date {
	func getMonthName() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM"
		let strMonth = dateFormatter.string(from: self)
		return strMonth
	}
}
