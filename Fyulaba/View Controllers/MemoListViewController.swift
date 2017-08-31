//
//  MemoListViewController.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import ReSwift
import ReSwiftRouter
import DZNEmptyDataSet

class MemoListViewController: UITableViewController, Routable {

    private var items = [MemoItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        clearsSelectionOnViewWillAppear = true
        tableView.emptyDataSetSource = self
        
        navigationItem.rightBarButtonItem = editButtonItem
        navigationController?.hidesNavigationBarHairline = true
        
        store.dispatch(fetchMemoItems(query: nil))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { state in
            state.memoItems
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        store.dispatch(fetchMemoItem(item.uuid))
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MemoListCell.identifier) as? MemoListCell
        
        guard let currentCell = cell else {
            fatalError("Identifier or class not registered with this table view")
        }
        
        let model = items[indexPath.row]
        currentCell.textLabel?.text = model.title
        currentCell.detailTextLabel?.text = model.subtitle
        currentCell.textLabel?.textAlignment = .center
        
        return currentCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = items[indexPath.row]
            store.dispatch(deleteMemoItem(item))
        } else if editingStyle == .insert {
            //
        }
    }
}

extension MemoListViewController: StoreSubscriber {
    func newState(state: MemoItemsState) {
        items = state.items
        
        tableView.reloadData()
        tableView.reloadEmptyDataSet()
        
        navigationItem.rightBarButtonItem?.isEnabled = state.items.count > 0
    }
}

extension MemoListViewController: DZNEmptyDataSetSource {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)]
        return NSAttributedString(string: "You don't seem to have any recordings", attributes: attributes)
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)]
        return NSAttributedString(string: "Go ahead and save speak and save some words.", attributes: attributes)
    }
}



