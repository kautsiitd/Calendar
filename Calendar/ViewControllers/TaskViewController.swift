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
    private var delegate: TodoProtocol
    private var date: Date
    private var todo: Todo
    private var isUpdating: Bool
    
    //MARK: Elements
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var priorityLabel: UILabel!
    @IBOutlet private weak var priorityLabelColorView: UIView!
    @IBOutlet private weak var titleField: UITextField!
    @IBOutlet private weak var commentsField: UITextView!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var priorityView: UIView!
    @IBOutlet private weak var priorityBlurView: UIVisualEffectView!
    @IBOutlet private weak var pickerViewWithToolBar: UIView!
    @IBOutlet private weak var pickerView: UIPickerView!
    
    //MARK: Constraints
    @IBOutlet private weak var pickerViewBottomConstraint: NSLayoutConstraint!
    
    init(delegate: TodoProtocol, date: Date, todos: Todo?) {
        self.delegate = delegate
        self.date = date
        let context = self.context
        self.todo = todos ?? Todo(entity: Todo.entity(), insertInto: context)
        self.todo.date = date
        isUpdating = todos != nil
        super.init(nibName: "\(TaskViewController.self)", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Method not Implemented!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentationController?.delegate = self
        setLayers()
        setData()
    }
    
    private func setLayers() {
        priorityLabelColorView.layer.cornerRadius = 3
        saveButton.layer.cornerRadius = 5
        deleteButton.layer.cornerRadius = 5
        deleteButton.isHidden = !isUpdating
        priorityView.isHidden = true
    }
    
    private func setData() {
        dateLabel.text = date.convertTo(string: "MMM d, yyyy")
        priorityLabel.text = todo.priority.getTitle()
        priorityLabelColorView.backgroundColor = todo.priority.getColor()
        titleField.text = todo.title
        let comment = todo.comments.isEmpty ? "Comments" : todo.comments
        commentsField.text = comment
        commentsField.textColor = todo.comments.isEmpty ? .lightGray : .black
        pickerView.selectRow(todo.priority.rawValue, inComponent: 0, animated: false)
    }
    
    private func dismissIt() {
        DispatchQueue.main.async { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: IBActions
extension TaskViewController {
    @IBAction private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else {
            return
        }
        //Finding If finger movement was enough to hide PriorityView as actionRatio reaches 1
        let ytransition = recognizer.translation(in: view).y
        let actionRatio = 1 - max(0,ytransition)/200
        priorityBlurView.alpha = 0.9*actionRatio
        pickerViewBottomConstraint.constant = actionRatio*pickerViewWithToolBar.frame.height
        //Doing Spring action to back to original if actionRatio is greater than 0.6
        if recognizer.state == .ended {
            _ = actionRatio > 0.6 ? showPriorityView() : hidePriorityView()
        }
    }
    
    @IBAction private func showPriorityView() {
        view.endEditing(true)
        isModalInPresentation = true
        priorityView.isHidden = false
        pickerViewBottomConstraint.constant = pickerViewWithToolBar.frame.height
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut,
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
                        self?.priorityBlurView.alpha = 0.9
            }, completion: nil)
    }
    
    @IBAction private func hidePriorityView() {
        pickerViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut,
                       animations: { [weak self] in
                        self?.view.layoutIfNeeded()
                        self?.priorityBlurView.alpha = 0
            }, completion: { [unowned self] _ in
                self.priorityView.isHidden = true
                self.isModalInPresentation = self.context.hasChanges
        })
    }
    
    @IBAction private func saveData() {
        authenticateUser { [unowned self] in
            Todos.shared.saveTodosIn(context: self.context)
            self.delegate.added(todo: self.todo)
            self.dismissIt()
        }
    }
    
    @IBAction private func deleteData() {
        authenticateUser { [unowned self] in
            self.context.delete(self.todo)
            Todos.shared.saveTodosIn(context: self.context)
            self.delegate.delete(todo: self.todo)
            self.dismissIt()
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
        view.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pullToDismiss(isEnable: false)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        pullToDismiss(isEnable: true)
        todo.title = textField.text ?? ""
    }
}

//MARK: UITextViewDelegate
extension TaskViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        pullToDismiss(isEnable: false)
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        pullToDismiss(isEnable: true)
        todo.comments = textView.text
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
        let priority = Priority(rawValue: row)!
        return priority.getTitle()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let priority = Priority(rawValue: row)!
        priorityLabel.text = priority.getTitle()
        priorityLabelColorView.backgroundColor = priority.getColor()
        todo.priority = priority
    }
}

extension TaskViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        //FIXME: Better way to handle PickerView pullToDismiss, asked on StackOverFlow
        if !priorityView.isHidden { return }
        if context.hasChanges {
            showActionSheet()
        }
    }
    
    private func showActionSheet() {
        let saveAction = UIAlertAction(title: "Save Changes",
                                       style: .default,
                                       handler: { [weak self] _ in
                                        self?.saveData()
        })
        let discardAction = UIAlertAction(title: "Discard Changes",
                                          style: .default,
                                          handler: { [weak self] _ in
                                            self?.context.rollback()
                                            self?.dismissIt()
        })
        let cancelAction = UIAlertAction(title: "Cancel",
                                          style: .cancel,
                                          handler: nil)
        
        let actionSheet = UIAlertController(title: nil, message: nil,
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(saveAction)
        actionSheet.addAction(discardAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return !context.hasChanges
    }
}
