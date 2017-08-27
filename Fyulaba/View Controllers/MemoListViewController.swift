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

    var tableDataSource: TableDataSource<MemoListCell, MemoItem>?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        self.tableView.emptyDataSetSource = self
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                target: self,
                                                                action: #selector(self.handleCancel))
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        fetchMemoItems(query: nil)
    }

    @objc func handleCancel(_ sender: UIBarButtonItem) {
        store.dispatch(RoutingAction(destination: .parent))
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

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let items = tableDataSource.map { cell, model in
//            return model
//        }
//        let item = store.dispatch(RoutingAction(destination: .memoDetail))
//    }
}

extension MemoListViewController: StoreSubscriber {
    func newState(state: MemoItemsState) {
        tableDataSource = TableDataSource(cellIdentifier: MemoListCell.identifier,
                                          models: state.items) { cell, model in
            cell.textLabel?.text = model.title
            cell.textLabel?.textAlignment = .center
            return cell
        }
        tableView.dataSource = tableDataSource
        tableView.reloadData()
        tableView.reloadEmptyDataSet()
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



