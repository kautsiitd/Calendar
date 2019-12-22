//
//  TaskViewController.swift
//  Calendar
//
//  Created by Kautsya Kanu on 21/11/19.
//  Copyright © 2019 Kautsya Kanu. All rights reserved.
//

import UIKit
import CoreData
import LocalAuthentication

class TaskViewController: UIViewController {
    
    //MARK: Properties
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    private var delegate: TodoProtocol?
    private var date: Date
    private var todo: Todo?
    
    //MARK: Elements
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var priorityLabel: UILabel!
    @IBOutlet private weak var priorityLabelColorView: UIView!
    @IBOutlet private weak var titleField: UITextField!
    @IBOutlet private weak var commentsField: UITextView!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var priorityPickerView: UIView!
    
    init(delegate: TodoProtocol?, date: Date, todos: Todo?) {
        self.delegate = delegate
        self.date = date
        self.todo = todos
        super.init(nibName: "\(TaskViewController.self)", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Method not Implemented!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayouts()
        setData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var frame = self.priorityPickerView.frame
        frame.origin.y += frame.height
        self.priorityPickerView.frame = frame
    }
    
    private func setLayouts() {
        priorityLabelColorView.layer.cornerRadius = 3
        saveButton.layer.cornerRadius = 5
        deleteButton.layer.cornerRadius = 5
        deleteButton.isHidden = (todo == nil)
        priorityPickerView.isHidden = true
    }
    
    private func setData() {
        dateLabel.text = date.convertTo(string: "MMM d, yyyy")
        priorityLabel.text = todo?.priority.getTitle() ?? Priority.getTitle(.interview)()
        priorityLabelColorView.backgroundColor = todo?.priority.getColor() ?? Priority.getColor(.interview)()
        titleField.text = todo?.title ?? ""
        guard let comment = todo?.comments,
            comment != "" else {
                commentsField.text = "Comments"
                commentsField.textColor = UIColor.lightGray
                return
        }
        commentsField.text = comment
        commentsField.textColor = UIColor.black
    }
    
    private func save(todo: Todo) {
        DispatchQueue.main.async {
            todo.date = self.date
            let priorityColor = self.priorityLabelColorView.backgroundColor ?? Priority.getColor(.interview)()
            todo.priority = Priority.getPriorityFrom(color: priorityColor)
            todo.title = self.titleField.text ?? ""
            todo.comments = self.commentsField.textColor == UIColor.black ? self.commentsField.text : ""
        }
        CoreDataStack.shared.save(context: self.context)
        self.delegate?.added(todo: todo)
        DispatchQueue.main.async { [unowned self] in
            self.dismiss(animated: true,
            completion: nil)
        }
    }
    
    deinit {
        view.endEditing(true)
    }
}

//MARK: IBActions
extension TaskViewController {
    @IBAction private func selectPriority() {
        if !priorityPickerView.isHidden {
            return
        }
        priorityPickerView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
            var frame = self.priorityPickerView.frame
            frame.origin.y -= frame.height
            self.priorityPickerView.frame = frame
        })
    }
    
    @IBAction private func DonePriority() {
        UIView.animate(withDuration: 0.2, animations: { [unowned self] in
            var frame = self.priorityPickerView.frame
            frame.origin.y += frame.height
            self.priorityPickerView.frame = frame
            }, completion: { _ in
                self.priorityPickerView.isHidden = true
        })
    }
    
    @IBAction private func saveData() {
        authenticateUser { [unowned self] in
            guard let todo = self.todo else {
                let object = Todo(entity: Todo.entity(),
                                  insertInto: self.context)
                self.save(todo: object)
                return
            }
            
            guard let object = self.context.object(with: todo.objectID) as? Todo else {
                DispatchQueue.main.async { [unowned self] in
                    self.dismiss(animated: true,
                    completion: nil)
                }
                return
            }
            self.save(todo: object)
        }
    }
    
    @IBAction private func deleteData() {
        guard let todo = todo else {
            return
        }
        authenticateUser { [unowned self] in
            self.context.delete(todo)
            CoreDataStack.shared.save(context: self.context)
            self.delegate?.delete(todo: todo)
            DispatchQueue.main.async { [unowned self] in
                self.dismiss(animated: true,
                completion: nil)
            }
        }
    }
}

//MARK: LocalAuthentication
extension TaskViewController {
    func authenticateUser(completion: @escaping () -> Void) {
        let context = LAContext()
        let reason = "Please verify to make changes"
        context.evaluatePolicy(.deviceOwnerAuthentication,
                               localizedReason: reason,
                               reply: { success, error in
                                if success{ completion() }
        })
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

//MARK: UIPickerViewDataSource
extension TaskViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Priority.allCases.count
    }
}

//MARK: UIPickerViewDelegate
extension TaskViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Priority.getTitle(Priority(rawValue: row)!)()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        priorityLabel.text = Priority.getTitle(Priority(rawValue: row)!)()
        priorityLabelColorView.backgroundColor = Priority.getColor(Priority(rawValue: row)!)()
    }
}
