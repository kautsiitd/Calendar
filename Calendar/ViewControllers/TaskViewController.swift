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
    private var delegate: TodoProtocol?
    private var date: Date
    private var todo: Todo?
    
    //MARK: Elements
    @IBOutlet private weak var titleField: UITextField!
    @IBOutlet private weak var commentsField: UITextView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var saveButton: UIButton!
    
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
        let todo = Todo(entity: Todo.entity(),
                        insertInto: context)
        todo.date = date
        todo.title = titleField.text ?? ""
        todo.comments = commentsField.textColor == UIColor.black ? commentsField.text : ""
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                fatalError("Data could not be Saved")
            }
        }
        delegate?.added(todo: todo)
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
