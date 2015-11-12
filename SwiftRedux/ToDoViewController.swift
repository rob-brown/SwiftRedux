//
//  ToDoViewController.swift
//  SwiftRedux
//
//  Created by Robert Brown on 10/30/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import UIKit

class ToDoViewController: UITableViewController {
    
    @IBOutlet weak var undoButton: UIBarButtonItem?
    @IBOutlet weak var redoButton: UIBarButtonItem?
    
    var store: Store<History<AppState>>?
    var notifier: Notifier?
    private var todos = [ToDo]()
    private var unsubscribers = [Unsubscriber]()
    
    deinit {
        unsubscribers.forEach { $0() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let notifier = notifier else { return }
        unsubscribers += [notifier.todoNotifier.subscribe(todosChanged)]
        unsubscribers += [notifier.canUndoNotifier.subscribe(canUndoChanged)]
        unsubscribers += [notifier.canRedoNotifier.subscribe(canRedoChanged)]
        
        let gesture = UITapGestureRecognizer(target: self, action: "showHistory")
        gesture.numberOfTapsRequired = 3
        view.addGestureRecognizer(gesture)
    }
    
    func todosChanged(todos: [ToDo]) {
        self.todos = todos
        tableView.reloadData()
    }
    
    func canUndoChanged(canUndo: Bool) {
        undoButton?.enabled = canUndo
    }
    
    func canRedoChanged(canRedo: Bool) {
        redoButton?.enabled = canRedo
    }
    
    @IBAction func tappedAdd(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Create To Do", message: nil, preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { action in }
        let create = UIAlertAction(title: "Create", style: .Default) { [weak alert, weak self] action in
            guard let text = alert?.textFields?.first?.text else { return }
            let action = ToDoActionCreater.create(text)
            _ = try? self?.store?.dispatch(action)
        }
        alert.addAction(cancel)
        alert.addAction(create)
        alert.addTextFieldWithConfigurationHandler { textField in }
        showDetailViewController(alert, sender: nil)
    }
    
    func showHistory() {
        guard let store = store, notifier = notifier else { return }
        let history = HistoryViewController(store: store, notifier: notifier)
        let navController = UINavigationController(rootViewController: history)
        showDetailViewController(navController, sender: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ToDoCell")!
        let todo = todos[indexPath.row]
        cell.textLabel?.text = todo.text
        cell.accessoryType = todo.completed ? .Checkmark : .None
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let todo = todos[indexPath.row]
        let action: Action
        if todo.completed {
            action = ToDoActionCreater.restart(indexPath.row)
        }
        else {
            action = ToDoActionCreater.complete(indexPath.row)
        }
        _ = try? store?.dispatch(action)
    }
}
