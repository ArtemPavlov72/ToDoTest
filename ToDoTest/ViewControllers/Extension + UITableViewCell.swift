//
//  Extension + UITableViewCell.swift
//  ToDoTest
//
//  Created by Artem Pavlov on 07.08.2023.
//

import UIKit

extension UITableViewCell {
    func configure(with taskList: TaskList) {
        guard let taskLists = taskList.tasks?.allObjects as? [TaskCD] else { return }

        let currentTasks = taskLists.filter { task in
            task.isComplete == false
        }

        var content = defaultContentConfiguration()

        content.text = taskList.title

        if taskLists.isEmpty {
            content.secondaryText = "0"
            accessoryType = .none
        } else if currentTasks.isEmpty {
            content.secondaryText = nil
            accessoryType = .checkmark
        } else {
            content.secondaryText = "\(currentTasks.count)"
            accessoryType = .none
        }
        contentConfiguration = content
    }
}
