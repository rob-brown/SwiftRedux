//
//  ToDoViewController.swift
//  SwiftRedux
//
//  Created by Robert Brown on 10/30/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import UIKit

class ToDoViewController: UITableViewController {

    var store: Store?
    private var todos = [ToDo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todosChanged()
    }
    
    func todosChanged() {
        guard let state = store?.currentState() as? AppState else { return }
        todos = state.todos
        tableView.reloadData()
    }
    
    
    
    
    
    
}
