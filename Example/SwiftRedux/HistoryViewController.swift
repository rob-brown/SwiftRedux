//
//  HistoryViewController.swift
//  SwiftRedux
//
//  Created by Robert Brown on 11/10/15.
//  Copyright © 2015 Robert Brown. All rights reserved.
//

import UIKit

public class HistoryViewController<T>: UITableViewController {
    private var store: Store<History<T>>
    private var notifier: Notifier
    private var unsubscribers = [Unsubscriber]()
    
    public init(store: Store<History<T>>, notifier: Notifier) {
        self.store = store
        self.notifier = notifier
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        unsubscribers.forEach { $0() }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        unsubscribers.append(notifier.stateNotifier.subscribe { [weak self] state in
            self?.tableView.reloadData()
            })
        setUpToolbar()
    }
    
    private func setUpToolbar() {
        let done = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismiss")
        let undo = UIBarButtonItem(barButtonSystemItem: .Undo, target: self, action: "undo")
        let redo = UIBarButtonItem(barButtonSystemItem: .Redo, target: self, action: "redo")
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        setToolbarItems([redo, space, undo], animated: false)
        navigationController?.setToolbarHidden(false, animated: false)
        navigationItem.rightBarButtonItem = done
        
        undo.enabled = store.currentState().canUndo()
        redo.enabled = store.currentState().canRedo()
        
        unsubscribers.append(notifier.canUndoNotifier.subscribe { canUndo in
            undo.enabled = canUndo
            })
        unsubscribers.append(notifier.canRedoNotifier.subscribe { canRedo in
            redo.enabled = canRedo
            })
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func undo() {
        _ = try? store.dispatch(HistoryAction.createUndo())
    }
    
    func redo() {
        _ = try? store.dispatch(HistoryAction.createRedo())
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let history = store.currentState()
        return history.past.count + history.future.count + 1
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellID = "cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID) ?? UITableViewCell(style: .Default, reuseIdentifier: cellID)
        let item = fetch(indexPath)
        
        cell.textLabel?.text = item.action.type
        
        if isCurrentState(indexPath) {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let history = store.currentState()
        if isPastState(indexPath) {
            let steps = history.past.count - indexPath.row
            let action = HistoryAction.jumpBack(steps)
            _ = try? store.dispatch(action)
        }
        else if isCurrentState(indexPath) {
            // Do nothing
        }
        else if isFutureState(indexPath) {
            let steps = indexPath.row - history.past.count
            let action = HistoryAction.jumpForward(steps)
            _ = try? store.dispatch(action)
        }
        else {
            fatalError("Impossible state")
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    private func fetch(indexPath: NSIndexPath) -> HistoryItem<T> {
        
        // ???: Should I reverse the order so the first action is last?
        
        let history = store.currentState()
        if isPastState(indexPath) {
            let adjustedIndex = history.past.count - indexPath.row - 1
            return history.past[adjustedIndex]
        }
        else if isCurrentState(indexPath) {
            return history.current
        }
        else if isFutureState(indexPath) {
            let adjustedIndex = indexPath.row - history.past.count - 1
            return history.future[adjustedIndex]
        }
        else {
            fatalError("Impossible state")
        }
    }
    
    private func isCurrentState(indexPath: NSIndexPath) -> Bool {
        let history = store.currentState()
        return indexPath.row == history.past.count
    }
    
    private func isPastState(indexPath: NSIndexPath) -> Bool {
        let history = store.currentState()
        return indexPath.row < history.past.count
    }
    
    private func isFutureState(indexPath: NSIndexPath) -> Bool {
        let history = store.currentState()
        return indexPath.row > history.past.count
    }
}
