//
//  StorageManager.swift
//  ToDoTest
//
//  Created by Artem Pavlov on 07.08.2023.
//

import CoreData

class StorageManager {
    static let shared = StorageManager()

    // MARK: - Core Data stack
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private let viewContext: NSManagedObjectContext

    init() {
        viewContext = persistentContainer.viewContext
    }

    //MARK: - Methods of TaskList
    func fetchTaskList(completion: (Result<[TaskList], Error>) -> Void) {
        let fetchRequest = TaskList.fetchRequest()

        do {
            let tasksLists = try viewContext.fetch(fetchRequest)
            completion(.success(tasksLists))
        } catch let error {
            completion(.failure(error))
        }
    }

    func saveTasklist(nameOfTaskList: String) {
        let taskList = TaskList(context: viewContext)
        taskList.title = nameOfTaskList
        saveContext()
    }

    func editTaskList(_ taskList: TaskList, newTaskListName: String) {
        taskList.title = newTaskListName
        saveContext()
    }

    func deleteTaskList(_ tasklist: TaskList) {
        viewContext.delete(tasklist)
        saveContext()
    }

    func addDoneFor(_ taskList: TaskList) {
        taskList.tasks?.setValue(true, forKey: "isComplete")
        saveContext()
    }

    //MARK: - Methods of Task
    func saveTask(_ taskName: String, note text: String, to taskListed: TaskList?) {
        let task = TaskCD(context: viewContext)
        task.title = taskName
        task.note = text
        task.taskList = taskListed
        saveContext()
    }

    func editTask(_ task: TaskCD, withNewName name: String, andNote note: String) {
        task.title = name
        task.note = note
        saveContext()
    }

    func deleteTask(_ task: TaskCD) {
        viewContext.delete(task)
        saveContext()
    }

    func addDoneFor(_ task: TaskCD) {
        task.isComplete.toggle()
        saveContext()
    }

    // MARK: - Core Data Saving support
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
