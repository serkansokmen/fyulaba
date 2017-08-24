//
//  TableDataSource.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit

/// This class is a simple, immutable, declarative data source for UITableView
final class TableDataSource<V, T> : NSObject, UITableViewDataSource where V: UITableViewCell {

    typealias CellConfiguration = (V, T) -> V

    private let models: [T]
    private let configureCell: CellConfiguration
    private let cellIdentifier: String

    init(cellIdentifier: String, models: [T], configureCell: @escaping CellConfiguration) {
        self.models = models
        self.cellIdentifier = cellIdentifier
        self.configureCell = configureCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? V

        guard let currentCell = cell else {
            fatalError("Identifier or class not registered with this table view")
        }

        let model = models[indexPath.row]
        return configureCell(currentCell, model)
    }

    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
}

