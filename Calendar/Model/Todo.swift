//
//  Todo.swift
//  Calendar
//
//  Created by Kautsya Kanu on 11/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation
import CoreData

class Todo: NSManagedObject {
    //MARK: Properties
    @NSManaged var date: Date
    @NSManaged var title: String
    @NSManaged var comments: String
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }
}
