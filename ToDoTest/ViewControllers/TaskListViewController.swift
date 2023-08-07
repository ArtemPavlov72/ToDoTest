//
//  TaskListViewController.swift
//  ToDoTest
//
//  Created by Artem Pavlov on 07.08.2023.
//

import UIKit
import CoreData

protocol TaskListViewControllerDelegate {
    func reloadTaskLists()
}

class TaskListViewController: UITableViewController {

    //MARK: - Private Properties
    private let cellID = "cell"
    private var taskLists: [TaskList] = []

    // MARK: - Life Cycles Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        registerCell()
        setupNavigationBar()
        fetchTaskLists()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value2, reuseIdentifier: cellID)
        let taskList = taskLists[indexPath.row]
        cell.configure(with: taskList)
        return cell
    }

    //MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let taskList = taskLists[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            self.taskLists.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            StorageManager.shared.deleteTaskList(taskList)
        }

        let editAction = UIContextualAction(style: .normal, title: "Edit") { _, _, isDone in
            self.showAlert(taskList: taskList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }

        let doneAction = UIContextualAction(style: .normal, title: "Perfom") { _, _, isDone in
            StorageManager.shared.addDoneFor(taskList)
          tableView.reloadRows(at: [indexPath], with: .automatic)

          isDone(true)
        }

      editAction.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
      deleteAction.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
      doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)

      return UISwipeActionsConfiguration(actions: [deleteAction, doneAction, editAction])
    }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let taskList = taskLists[indexPath.row]
    let taskVC = TaskViewController()
    taskVC.taskList = taskList
        show(taskVC, sender: nil)
    }

    // MARK: - Private Methods
    private func setupNavigationBar() {
        title = "Task list"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addAction)
        )
    }

    @objc private func addAction() {
        let AddInfoVC = AddInfoViewController()
        AddInfoVC.delegateTaskList = self
        AddInfoVC.isTaskList = true
        present(AddInfoVC, animated: true)
    }

    private func fetchTaskLists() {
        StorageManager.shared.fetchTaskList { result in
            switch result {
            case .success(let taskLists):
                self.taskLists = taskLists
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    private func registerCell() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
}

//MARK: - Delegate Tasks
extension TaskListViewController: TaskListViewControllerDelegate {
    func reloadTaskLists() {
        fetchTaskLists()
        tableView.reloadData()
    }
}

//MARK: - Alert Controller
extension TaskListViewController {
    private func showAlert(taskList: TaskList?, completion: (() -> Void)?) {
        let alert = UIAlertController.createAlert(withTitle: "Editing the list name", andMessage: "Enter a new list name")

        alert.taskListAction(taskList: taskList) { taskName in
            if let taskList = taskList, let completion = completion {
                StorageManager.shared.editTaskList(taskList, newTaskListName: taskName)
                completion()
            }
        }
        present(alert, animated: true)
    }
}
