//
//  TaskViewController.swift
//  ToDoTest
//
//  Created by Artem Pavlov on 07.08.2023.
//

import UIKit
import CoreData

protocol TaskViewControllerDelegate {
  func reloadTasks()
}

class TaskViewController: UITableViewController {
  
  //MARK: - Private Properties

  private let cellID = "cell"
  private var currentTasks: [TaskCD] = []
  private var completedTasks: [TaskCD] = []

  //MARK: - Public Properties

  var taskList: TaskList?
  
  // MARK: - Life Cycles Methods

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    registerCell()
    setupNavigationBar()
    loadTasks()
  }
  
  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    2
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    section == 0 ? "Current tasks" : "Completed tasks"
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    section == 0 ? currentTasks.count : completedTasks.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
    let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
    var content = cell.defaultContentConfiguration()
    content.text = task.title
    content.secondaryText = task.note
    cell.contentConfiguration = content
    return cell
  }
  
  //MARK: - Table View Delegate

  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
    
    let deleteAction = UIContextualAction(style: .normal, title: "Delete") { _, _, _ in
      if indexPath.section == 0 {
        self.currentTasks.remove(at: indexPath.row)
      } else {
        self.completedTasks.remove(at: indexPath.row)
      }
      
      tableView.deleteRows(at: [indexPath], with: .automatic)
      StorageManager.shared.deleteTask(task)
    }
    
    let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
      self.showAlert(task: task) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
      }
      isDone(true)
    }

    editAction.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    deleteAction.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)

    return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]

    if indexPath.section == 0 {
      let movableTask = self.currentTasks.remove(at: indexPath.row)
      self.completedTasks.append(movableTask)
    } else {
      let movableTask = self.completedTasks.remove(at: indexPath.row)
      self.currentTasks.append(movableTask)
    }

    StorageManager.shared.addDoneFor(task)

    let indexPathForCurrentTask = IndexPath(row: self.currentTasks.count - 1, section: 0)
    let indexPathForCompletedTask = IndexPath(row: self.completedTasks.count - 1, section: 1)
    let destinationIndex = indexPath.section == 0 ? indexPathForCompletedTask : indexPathForCurrentTask
    tableView.moveRow(at: indexPath, to: destinationIndex)
  }
  
  // MARK: - Private Methods

  private func setupNavigationBar() {
    title = taskList?.title
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .add,
      target: self,
      action: #selector(addAction)
    )
  }
  
  @objc private func addAction() {
    let AddInfoVC = AddInfoViewController()
    AddInfoVC.delegateTask = self
    AddInfoVC.isTaskList = false
    AddInfoVC.taskList = taskList
    present(AddInfoVC, animated: true)
  }
  
  private func loadTasks() {
    guard let taskLists = taskList?.tasks?.allObjects as? [TaskCD] else {return}
    currentTasks = taskLists.filter { !$0.isComplete }
    completedTasks = taskLists.filter { $0.isComplete }
  }
  
  private func registerCell() {
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
  }
}

//MARK: - Delegate Tasks

extension TaskViewController: TaskViewControllerDelegate {
  func reloadTasks() {
    loadTasks()
    tableView.reloadData()
  }
}

//MARK: - Alert Controller

extension TaskViewController {
  private func showAlert(task: TaskCD?, completion: (() -> Void)?) {
    let alert = UIAlertController.createAlert(withTitle: "Editing the note title", andMessage: "Enter a new note name")
    
    alert.taskAction(task: task) { newValue, note in
      if let task = task, let completion = completion {
        StorageManager.shared.editTask(task, withNewName: newValue, andNote: note)
        completion()
      }
    }
    present(alert, animated: true)
  }
}
