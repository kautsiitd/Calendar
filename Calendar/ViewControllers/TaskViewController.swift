//
//  TaskViewController.swift
//  Calendar
//
//  Created by Kautsya Kanu on 21/11/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit
import CoreData

class TaskViewController: UIViewController {
    
    //MARK: Properties
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    private var delegate: TodoProtocol?
    private var date: Date
    private var todo: Todo?
    
    //MARK: Elements
    @IBOutlet private weak var titleField: UITextField!
    @IBOutlet private weak var commentsField: UITextView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    
    init(delegate: TodoProtocol?, date: Date, todos: Todo?) {
        self.delegate = delegate
        self.date = date
        self.todo = todos
        super.init(nibName: "\(TaskViewController.self)", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.delegate = nil
        self.date = Date()
        self.todo = Todo()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.layer.cornerRadius = 5
        deleteButton.layer.cornerRadius = 5
        deleteButton.isHidden = (todo == nil)
        setData()
    }
    
    private func setData() {
        titleField.text = todo?.title ?? ""
        dateLabel.text = date.convertTo(string: "MMM d, yyyy")
        guard let comment = todo?.comments,
            comment != "" else {
                commentsField.text = "Comments"
                commentsField.textColor = UIColor.lightGray
                return
        }
        commentsField.text = comment
        commentsField.textColor = UIColor.black
    }
    
    @IBAction private func saveData() {
        guard let todo = todo else {
            let object = Todo(entity: Todo.entity(),
                            insertInto: context)
            save(todo: object)
            return
        }
        
        guard let object = context.object(with: todo.objectID) as? Todo else {
            dismiss(animated: true,
            completion: nil)
            return
        }
        save(todo: object)
    }
    
    private func save(todo: Todo) {
        todo.date = date
        todo.title = titleField.text ?? ""
        todo.comments = commentsField.textColor == UIColor.black ? commentsField.text : ""
        CoreDataStack.shared.save(context: context)
        delegate?.added(todo: todo)
        dismiss(animated: true,
                completion: nil)
    }
    
    @IBAction private func deleteData() {
        guard let todo = todo else {
            return
        }
        context.performAndWait {
            context.delete(todo)
            CoreDataStack.shared.save(context: context)
        }
        delegate?.delete(todo: todo)
        dismiss(animated: true,
                completion: nil)
    }
    
    deinit {
        view.endEditing(true)
    }
}

//MARK: UITextFieldDelegate
extension TaskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

//MARK: UITextViewDelegate
extension TaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Comments"
            textView.textColor = UIColor.lightGray
        }
    }
}
