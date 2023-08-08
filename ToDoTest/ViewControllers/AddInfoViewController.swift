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
    isTaskList ? (textField.returnKeyType = .done) : (textField.returnKeyType = .next)
    return textField
  }()
  
  private lazy var taskNoteTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Task Description"
    textField.borderStyle = .roundedRect
    textField.returnKeyType = .done
    return textField
  }()
  
  private lazy var saveButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    button.setTitle("Save", for: .normal)
    button.setTitleColor(.black, for: .highlighted)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    button.layer.cornerRadius = 8
    button.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
    return button
  }()
  
  private lazy var cancelButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
    button.setTitle("Cancel", for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    button.setTitleColor(.black, for: .highlighted)
    button.layer.cornerRadius = 8
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
    taskTextField.delegate = self
    taskNoteTextField.delegate = self
    configureLayout()
  }
  
  //MARK: - Private Methods

  @objc private func saveAction() {
    guard let inputText = taskTextField.text, !inputText.isEmpty else {
      return
    }

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
    dismiss(animated: true)
  }
  
  //MARK: - ConfigureLayout

  private func configureLayout() {
    let appearance = Appearance()

    [taskTextField, saveButton, cancelButton].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview($0)
    }

    NSLayoutConstraint.activate([
      saveButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      saveButton.widthAnchor.constraint(equalToConstant: appearance.buttonSize),
      saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

      cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: appearance.defaultInset),
      cancelButton.widthAnchor.constraint(equalToConstant: appearance.buttonSize),
      cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ])

    if !isTaskList {
      taskNoteTextField.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(taskNoteTextField)

      NSLayoutConstraint.activate([
        taskTextField.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: appearance.taskTextFieldBottomInset),
        taskTextField.widthAnchor.constraint(equalToConstant: appearance.textFieldSize),
        taskTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),

        taskNoteTextField.topAnchor.constraint(equalTo: taskTextField.bottomAnchor, constant: appearance.defaultInset),
        taskNoteTextField.widthAnchor.constraint(equalToConstant: appearance.textFieldSize),
        taskNoteTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
      ])
    } else {
      NSLayoutConstraint.activate([
        taskTextField.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: appearance.textFieldBottomInset),
        taskTextField.widthAnchor.constraint(equalToConstant: appearance.textFieldSize),
        taskTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
      ])
    }
  }
}

//MARK: - UITextFieldDelegate

extension AddInfoViewController: UITextFieldDelegate {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    view.endEditing(true)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == taskTextField, !isTaskList {
      taskNoteTextField.becomeFirstResponder()
    } else {
      saveAction()
    }
    return true
  }
}

// MARK: - Appearance

private extension AddInfoViewController {
  struct Appearance {
    let backgroundColor: UIColor = .systemGray6
    let buttonSize: CGFloat = UIScreen.main.bounds.width * 0.5
    let textFieldSize: CGFloat = UIScreen.main.bounds.width * 0.8
    let defaultInset: CGFloat = 20
    let textFieldBottomInset: CGFloat = -50
    let taskTextFieldBottomInset: CGFloat = -100
  }
}
