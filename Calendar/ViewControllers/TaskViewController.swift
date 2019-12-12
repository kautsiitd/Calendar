//
//  TaskViewController.swift
//  Calendar
//
//  Created by Kautsya Kanu on 21/11/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController {
    
    //MARK: Properties
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    private var date: Date
    private var todo: Todo?
    
    //MARK: Elements
    @IBOutlet private weak var titleField: UITextField!
    @IBOutlet private weak var commentsField: UITextField!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var saveButton: UIButton!
    
    init(date: Date, todos: Todo?) {
        self.date = date
        self.todo = todos
        super.init(nibName: "\(TaskViewController.self)", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.date = Date()
        self.todo = Todo()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.layer.cornerRadius = 5
        setData()
    }
    
    private func setData() {
        titleField.text = todo?.title ?? ""
        commentsField.text = todo?.comments ?? ""
        dateLabel.text = date.convertTo(string: "MMM d, yyyy")
    }
    
    @IBAction private func saveData() {
        let todo = Todo(entity: Todo.entity(),
                        insertInto: context)
        todo.date = date
        todo.title = titleField.text ?? ""
        todo.comments = commentsField.text ?? ""
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Data could not be Saved")
            }
        }
        dismiss(animated: true,
                completion: nil)
    }
}

//MARK: UITextFieldDelegate
extension TaskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
