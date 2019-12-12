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
    let context = CoreDataStack.shared.persistentContainer.viewContext
	var numberOfMonths: Int = 6
	
	// MARK: Variables
	var currentDateObject: Date
	var calendar: Calendar
	var monthWiseDates: [[Date]]
	var rowsForMonth: [Int]
    var todos: [String: Todo] = [:]
	
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
        
        do {
            let todos = try context.fetch(Todo.fetchRequest()) as [Todo]
            for todo in todos {
                self.todos[todo.date.uniqueId()] = todo
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
	}
}

//MARK: TableView
extension ViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return numberOfMonths
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(TableViewCell.self)", for: indexPath) as! TableViewCell
        cell.delegate = self
        cell.setCell(todos: self.todos,
                     datesOfMonth: self.monthWiseDates[indexPath.row],
                     numberOfRows: self.rowsForMonth[indexPath.row])
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 9+10+30+35+CGFloat(rowsForMonth[indexPath.row]*50)+10+9
	}
}

//MARK: CalendarCellProtocol
extension ViewController: CalendarCellProtocol {
    func openTaskFor(date: Date) {
        let taskViewController = TaskViewController(date: date,
                                                    todos: todos[date.uniqueId()])
        present(taskViewController, animated: true, completion: nil)
    }
}
