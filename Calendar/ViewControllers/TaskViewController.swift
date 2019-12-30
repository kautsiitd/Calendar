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

protocol TaskVCProtocol {
    func update(date: Date)
}

class TaskViewController: UIViewController {
    
    //MARK: Properties
    private var context = CoreDataStack.shared.persistentContainer.viewContext
    private var delegate: TaskVCProtocol
    private var date: Date
    
    //MARK: Variables
    private var todo: Todo!
    private var isNew: Bool = true
    private var hasChanges: Bool = false
    
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
    
    init(delegate: TaskVCProtocol, date: Date) {
        self.delegate = delegate
        self.date = date
        super.init(nibName: "\(TaskViewController.self)", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Method not Implemented!")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentationController?.delegate = self
        fetchTodo()
        setLayers()
        setData()
    }
    
    private func fetchTodo() {
        let request = Todo.fetchAllRequest()
        let predicate = NSPredicate(format: "date == %@", date as NSDate)
        request.predicate = predicate
        let todos = try? context.fetch(request)
        isNew = todos?.isEmpty ?? true
        todo = todos?.first ?? Todo(context: context)
        todo.date = date
    }
    
    private func setLayers() {
        priorityLabelColorView.layer.cornerRadius = 3
        saveButton.layer.cornerRadius = 5
        deleteButton.layer.cornerRadius = 5
        deleteButton.isHidden = isNew
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
    
    deinit {
        context.rollback()
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
            }, completion: { _ in
                self.priorityView.isHidden = true
                self.isModalInPresentation = self.hasChanges
        })
    }
    
    @IBAction private func saveData() {
        authenticateUser {
            try? self.context.save()
            self.delegate.update(date: self.date)
            self.dismissIt()
        }
    }
    
    @IBAction private func deleteData() {
        authenticateUser {
            self.context.delete(self.todo)
            try? self.context.save()
            self.delegate.update(date: self.date)
            self.dismissIt()
        }
    }
    
    private func dismissIt() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
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
        hasChanges = true
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
        hasChanges = true
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
        hasChanges = true
    }
}

extension TaskViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        //FIXME: Better way to handle PickerView pullToDismiss, asked on StackOverFlow
        if !priorityView.isHidden { return }
        if hasChanges { showActionSheet() }
    }
    
    private func showActionSheet() {
        let saveAction = UIAlertAction(title: "Save Changes",
                                       style: .default,
                                       handler: { _ in self.saveData() })
        let discardAction = UIAlertAction(title: "Discard Changes",
                                          style: .default,
                                          handler: { _ in
                                            self.context.rollback()
                                            self.dismissIt()
        })
        let cancelAction = UIAlertAction(title: "Cancel",
                                          style: .cancel,
                                          handler: nil)
        
        let actionSheet = UIAlertController(title: nil, message: nil,
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(saveAction)
        actionSheet.addAction(discardAction)
        actionSheet.addAction(cancelAction)
        actionSheet.pruneNegativeWidthConstraints()
        present(actionSheet, animated: true, completion: nil)
    }
    
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return !hasChanges
    }
}
