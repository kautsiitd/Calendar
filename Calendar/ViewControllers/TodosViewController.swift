//
//  TodosViewController.swift
//  Calendar
//
//  Created by Kautsya Kanu on 21/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit
import CoreData

class TodosViewController: UIViewController {
    //MARK: Properties
    private var fetchedRC: NSFetchedResultsController<Todo>!
    //MARK: Elements
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTodos()
        noDataLabel.isHidden = !(fetchedRC.fetchedObjects?.isEmpty ?? true)
    }
    
    private func fetchTodos() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let request = Todo.fetchAllRequest()
        let dateSort = NSSortDescriptor(key: #keyPath(Todo.date), ascending: true)
        request.sortDescriptors = [dateSort]
        fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedRC.performFetch()
        } catch let error as NSError {
            fatalError(error.debugDescription)
        }
    }
}

extension TodosViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedRC.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(TodosTableViewCell.self)") as! TodosTableViewCell
        DispatchQueue.main.async {
            let todo = self.fetchedRC.object(at: indexPath)
            cell.setCell(todo: todo)
        }
        return cell
    }
}
