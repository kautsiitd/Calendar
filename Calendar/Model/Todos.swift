//
//  Todos.swift
//  Calendar
//
//  Created by Kautsya Kanu on 21/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import Foundation

enum TodosKey {
    case date
    case index
}

class Todos {
    //MARK: Properties
    static let shared = Todos()
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    private var todos: [Todo] = []
    
    private init() {
        self.updateTodos()
    }
    
    private func updateTodos() {
        do {
            todos = try context.fetch(Todo.fetchRequest()) as [Todo]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func getTodosDictWith(key: TodosKey) -> [String: Todo] {
        updateTodos()
        var todosDict: [String: Todo] = [:]
        switch key {
        case .date:
            for todo in todos {
                todosDict[todo.date.uniqueId()] = todo
            }
        case .index:
            for index in 0..<todos.count {
                todosDict["\(index)"] = todos[index]
            }
        }
        return todosDict
    }
}
