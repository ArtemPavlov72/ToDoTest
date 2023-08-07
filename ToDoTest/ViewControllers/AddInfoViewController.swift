//
//  AddInfoViewController.swift
//  ToDoTest
//
//  Created by Artem Pavlov on 07.08.2023.
//

import UIKit
import CoreData

class AddInfoViewController: UIViewController {

    //MARK: - Private Properties
    private lazy var taskTextField: UITextField = {
        let textField = UITextField()
        isTaskList ? (textField.placeholder = "New list") : (textField.placeholder = "New task")
        textField.borderStyle = .roundedRect
        return textField
    }()

    private lazy var taskNoteTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Task Description"
        textField.borderStyle = .roundedRect
        return textField
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return button
    }()

    //MARK: - Public Properties
    var delegateTaskList: TaskListViewControllerDelegate?
    var delegateTask: TaskViewControllerDelegate?
    var taskList: TaskList?
    var isTaskList = true

    //MARK: - Life Cycles Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setupSubviewsIf(isTaskList)
        setupConstraints()
    }

    //MARK: - Private Methods
    private func setupSubviews(_ subviews: UIView...) {
        subviews.forEach { subview in
            view.addSubview(subview)
        }
    }

    private func setupSubviewsIf(_ taskList: Bool) {
        taskList == true
        ? setupSubviews(taskTextField, saveButton, cancelButton)
        : setupSubviews(taskTextField, taskNoteTextField, saveButton, cancelButton)
    }

    @objc private func saveAction() {
        self.saveButton.pulsate()
        guard let inputText = taskTextField.text, !inputText.isEmpty else { return }
        if isTaskList {
            StorageManager.shared.saveTasklist(nameOfTaskList: inputText)
            delegateTaskList?.reloadTaskLists()
        } else {
            let inputNoteText = taskNoteTextField.text ?? ""
            StorageManager.shared.saveTask(inputText, note: inputNoteText, to: taskList)
            delegateTask?.reloadTasks()
        }
        dismiss(animated: true)
    }

    @objc private func cancelAction() {
        self.cancelButton.pulsate()
        dismiss(animated: true)
    }

    //MARK: - Constraints
    private func setupConstraints() {
        taskTextField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            taskTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            taskTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            taskTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])

        addTaskNoteTextFieldToConstraints(if: isTaskList)

        saveButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(
                equalTo:
                    isTaskList ? taskTextField.bottomAnchor : taskNoteTextField.bottomAnchor,
                constant:
                    70
            ),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100)
        ])

        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100)
        ])
    }

    private func addTaskNoteTextFieldToConstraints(if tasklist: Bool) {
        if tasklist == false {
            taskNoteTextField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                taskNoteTextField.topAnchor.constraint(equalTo: taskTextField.bottomAnchor, constant: 30),
                taskNoteTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
                taskNoteTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
            ])
        }
    }
}
