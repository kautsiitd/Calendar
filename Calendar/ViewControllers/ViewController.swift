//
//  ViewController.swift
//  Calendar
//
//  Created by Kautsya Kanu on 15/11/17.
//  Copyright © 2017 Kautsya Kanu. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UITableViewController {
	
	// MARK: Constants
	var numberOfMonths: Int = 6
	
	// MARK: Variables
	var currentDateObject: Date
	var calendar: Calendar
	var monthWiseDates: [[Date]]
	var rowsForMonth: [Int]
	
	// MARK: Init
	required init?(coder aDecoder: NSCoder) {
		currentDateObject = Date()
		calendar = Calendar.current
		
		var midDate = currentDateObject
		while Calendar.current.component(.day, from: midDate) != 1 {
			midDate = calendar.date(byAdding: .day, value: -1, to: midDate)!
		}
		monthWiseDates = []
		rowsForMonth = []
		var monthCount = 0
		while monthCount < numberOfMonths {
			var tempMonthDates: [Date] = []
			let monthStartDate = midDate
			let currentMonth = calendar.dateComponents([.month], from: monthStartDate)
			while calendar.dateComponents([.month], from: midDate) == currentMonth {
				tempMonthDates.append(midDate)
				midDate = calendar.date(byAdding: .day, value: 1, to: midDate)!
			}
			monthWiseDates.append(tempMonthDates)
			
			let numberOfDates = tempMonthDates.count
			let offset = calendar.dateComponents([.weekday], from: monthStartDate).weekday! - 1
			if (numberOfDates+offset)%7 == 0 {
    			self.rowsForMonth.append((numberOfDates+offset)/7)
			}
			else {
				self.rowsForMonth.append((numberOfDates+offset)/7 + 1)
			}
			monthCount += 1
		}
		
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
	}
}

extension ViewController {
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return numberOfMonths
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
		cell.setCell(datesOfMonth: self.monthWiseDates[indexPath.row], numberOfRows: self.rowsForMonth[indexPath.row])
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 10+30+35+CGFloat(rowsForMonth[indexPath.row]*50)+10
	}
}

