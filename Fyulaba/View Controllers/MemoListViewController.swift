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

class MemoListViewController: UITableViewController {

    var tableDataSource: TableDataSource<MemoListCell, MemoItem>?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        self.tableView.emptyDataSetSource = self
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                target: self,
                                                                action: #selector(self.handleCancel))
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @objc func handleCancel(_ sender: UIBarButtonItem) {
        store.dispatch(RoutingAction(destination: .parent))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { state in
            state.memoItems
        }
        store.dispatch(FetchMemoListAction(query: nil))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
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
            self.tableDataSource = TableDataSource(cellIdentifier: MemoListCell.identifier, models: items) { cell, model in
                cell.textLabel?.text = model.title
                cell.textLabel?.textAlignment = .center
                return cell
            }
            self.tableView.dataSource = tableDataSource
            self.tableView.reloadData()
            self.tableView.reloadEmptyDataSet()
        case let .error(error):
            self.showAlert(error?.localizedDescription, type: .warning)
        }
    }
}

extension MemoListViewController: Routable {

}

// MARK: - Table view data source
extension MemoListViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        self.presentRecorder(with: item)
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
//            let item = self.items[indexPath.row]
//            store.dispatch(DeleteMemoAction(item: item))
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



