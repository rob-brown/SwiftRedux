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
    
    
    
    
    
    
}
