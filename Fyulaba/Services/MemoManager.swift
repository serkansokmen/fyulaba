//
//  MemoManager.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import Disk
import AudioKit

final class MemoManager: PersistanceManager  {
    
    static let shared: MemoManager = {
        let instance = MemoManager()
        // setup code
        return instance
    }()

    func getItems(query: String?, completion completionHandler: ItemsCompletion<MemoItem>) throws {
        let items = try Disk.retrieve("recordings.json", from: .documents, as: [MemoItem].self)
        completionHandler?(items)
    }

    func getItem(uuid: String, completion completionHandler: ItemCompletion<MemoItem>) throws {
        let items = try Disk.retrieve("recordings.json", from: .documents, as: [MemoItem].self)
        completionHandler?(items.filter { $0.uuid == uuid }.first)
    }

    func addItem(item: MemoItem, completion completionHandler: ItemsCompletion<MemoItem>) throws {
        try updateItem(item: item) { newItems in
            completionHandler?(newItems)
        }
    }

    func updateItem(item: MemoItem, completion completionHandler: ItemsCompletion<MemoItem>) throws {
        var items = [MemoItem]()
        if Disk.exists("recordings.json", in: .documents) {
            items = try Disk.retrieve("recordings.json", from: .documents, as: [MemoItem].self)
        }
        var newItems = items
        if let existingIndex = newItems.index(where: { $0.uuid == item.uuid }) {
            newItems[existingIndex] = item
        } else {
            newItems.append(item)
        }
        try? Disk.save(newItems, to: .documents, as: "recordings.json")
        completionHandler?(newItems)
    }

    func deleteItem(item: MemoItem, completion completionHandler: ItemsCompletion<MemoItem>) throws {
        let items = try Disk.retrieve("recordings.json", from: .documents, as: [MemoItem].self)
        let newItems = items
            .filter { $0.uuid != item.uuid }
        try Disk.save(newItems, to: .documents, as: "recordings.json")
        if let fileURL = item.fileURL {
            try Disk.remove(fileURL.lastPathComponent, from: .documents)
        }
        completionHandler?(newItems)
    }
}

