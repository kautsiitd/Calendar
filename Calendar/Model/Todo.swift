//
//  Todo.swift
//  Calendar
//
//  Created by Kautsya Kanu on 11/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc enum Priority: Int, CaseIterable {
    case interview, coding, shopping, birthday, holiday
    
    static func getPriorityFrom(title: String?) -> Priority {
        switch title {
        case "Interview":
            return Priority(rawValue: 0)!
        case "Coding":
            return Priority(rawValue: 1)!
        case "Shopping":
            return Priority(rawValue: 2)!
        case "Birthday":
            return Priority(rawValue: 3)!
        case "Holiday":
            return Priority(rawValue: 4)!
        default:
            return Priority(rawValue: 0)!
        }
    }
    
    func getTitle() -> String {
        switch self {
        case .interview:
            return "Interview"
        case .coding:
            return "Coding"
        case .shopping:
            return "Shopping"
        case .birthday:
            return "Birthday"
        case .holiday:
            return "Holiday"
        }
    }
    
    func getColor() -> UIColor {
        switch self {
        case .interview:
            return .red
        case .coding:
            return .blue
        case .shopping:
            return .yellow
        case .birthday:
            return .brown
        case .holiday:
            return .lightGray
        }
    }
}

protocol TodoProtocol {
    func added(todo: Todo)
    func delete(todo: Todo)
}

class Todo: NSManagedObject {
    //MARK: Properties
    @NSManaged var date: Date
    @NSManaged var title: String
    @NSManaged var comments: String
    @NSManaged var priority: Priority
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }
}
