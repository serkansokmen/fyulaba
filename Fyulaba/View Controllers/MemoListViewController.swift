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

        clearsSelectionOnViewWillAppear = true
        tableView.emptyDataSetSource = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.handleCancel))
        navigationItem.rightBarButtonItem = editButtonItem
        navigationController?.hidesNavigationBarHairline = true
        store.subscribe(self) { state in
            state.memoItems
        }
        fetchMemoItems(query: nil)
    }
    
    deinit {
        store.unsubscribe(self)
    }

    @objc func handleCancel(_ sender: UIBarButtonItem) {
        store.dispatch(RoutingAction(destination: .root))
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        store.dispatch(SelectedRow())
//        tableDataSource
//        _ = tableDataSource.map { items in
//            let memoItems = items.map<> { cell, item in
//                let item = items[indexPath.row]
//                print(item)
//            }
////            let item = store.dispatch(RoutingAction(destination: .memoDetail))
//        }
    }
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



