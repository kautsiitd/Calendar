//
//  TodosViewController.swift
//  Calendar
//
//  Created by Kautsya Kanu on 21/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit

class TodosViewController: UIViewController {
    //MARK: Properties
    private var todos: [String: Todo] = [:]
    //MARK: Elements
    @IBOutlet private weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todos = Todos.shared.getTodosDictWith(key: .index)
    }
}

extension TodosViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(TodosTableViewCell.self)") as? TodosTableViewCell,
            let todo = todos["\(indexPath.row)"] else {
            return UITableViewCell()
        }
        cell.setCell(todo: todo)
        return cell
    }
}
