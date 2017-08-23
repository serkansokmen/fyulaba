//
//  MemoListViewController.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import ReSwift
import DZNEmptyDataSet

class MemoListViewController: UITableViewController {

    static let identifier = "MemoListViewController"
    static let navigationIdentifier = "MemoListNavigationController"

    var items = [MemoItem]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        self.tableView.emptyDataSetSource = self
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                target: nil,
                                                                action: #selector(self.handleCancel))
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @objc func handleCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension MemoListViewController: StoreSubscriber {
    func newState(state: MemoItemsState) {
        switch state {
        case .none:
            break
        case .loading:
            break
        case let .success(items):
            self.items = items
            self.tableView.reloadData()
            self.tableView.reloadEmptyDataSet()
        case let .error(error):
            self.showAlert(error?.localizedDescription, type: .warning)
        }
    }
}

// MARK: - Table view data source
extension MemoListViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: MemoListCell.identifier, for: indexPath)
        let item = self.items[indexPath.row]
        print(item)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
//        self.presentRecorder(with: item)
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = self.items[indexPath.row]
            store.dispatch(DeleteMemoAction(item: item))
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
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


