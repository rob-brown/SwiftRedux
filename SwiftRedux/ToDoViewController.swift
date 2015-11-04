//
//  ToDoViewController.swift
//  SwiftRedux
//
//  Created by Robert Brown on 10/30/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import UIKit

class ToDoViewController: UITableViewController {

    var store: Store<AppState>?
    private var todos = [ToDo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todosChanged()
    }
    
    func todosChanged() {
        todos = store?.currentState().todos ?? todos
        tableView.reloadData()
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
        guard todo.completed == false else { return }
        let action = ToDoActionCreater.complete(indexPath.row)
        _ = try? store?.dispatch(action)
    }
}
