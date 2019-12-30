//
//  TodosViewController.swift
//  Calendar
//
//  Created by Kautsya Kanu on 21/12/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit
import CoreData

enum SortType {
    case date, title, priority
    
    func getRequest() -> NSFetchRequest<Todo> {
        let request = Todo.fetchAllRequest()
        let sort: NSSortDescriptor
        switch self {
        case .date:
            sort = NSSortDescriptor(key: #keyPath(Todo.date), ascending: true)
        case .title:
            sort = NSSortDescriptor(key: #keyPath(Todo.title), ascending: true)
        case .priority:
            sort = NSSortDescriptor(key: #keyPath(Todo.priority), ascending: true)
        }
        request.sortDescriptors = [sort]
        return request
    }
}

class TodosViewController: UIViewController {
    //MARK: Properties
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    private var fetchedRC: NSFetchedResultsController<Todo>!
    //MARK: Elements
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noDataLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchSortTodos(for: .date)
        noDataLabel.isHidden = !(fetchedRC.fetchedObjects?.isEmpty ?? true)
    }
    
    private func setupTableView() {
        //FIXME: Try to use automaticDimension for reload
        tableView.rowHeight = 87
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private func fetchSortTodos(for sort: SortType) {
        let request = sort.getRequest()
        fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedRC.performFetch()
        } catch let error as NSError {
            fatalError(error.debugDescription)
        }
    }
}

//MARK: UITableViewDataSource
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

//MARK: IBActions
extension TodosViewController {
    @IBAction private func showFilters() {
        let dateSort = UIAlertAction(title: "Date", style: .default, handler: { _ in
            self.applySort(of: .date)
        })
        let titleSort = UIAlertAction(title: "Title", style: .default, handler: { _ in
            self.applySort(of: .title)
        })
        let prioritySort = UIAlertAction(title: "Priority", style: .default, handler: { _ in
            self.applySort(of: .priority)
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let actionSheet = UIAlertController(title: nil, message: nil,
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(dateSort)
        actionSheet.addAction(titleSort)
        actionSheet.addAction(prioritySort)
        actionSheet.addAction(cancel)
        actionSheet.pruneNegativeWidthConstraints()
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func applySort(of type: SortType) {
        fetchSortTodos(for: type)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
