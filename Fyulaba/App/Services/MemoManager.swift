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

struct MemoManager: PersistanceManager  {

    func getItems(query: String?, completionHandler completion: @escaping ItemsCompletion<MemoItem>) throws {
        let items = try Disk.retrieve("recordings.json", from: .documents, as: [MemoItem].self)
        completion(items)
    }

    func getItem(uuid: String, completionHandler completion: @escaping ItemCompletion<MemoItem?>) throws {
        let items = try Disk.retrieve("recordings.json", from: .documents, as: [MemoItem].self)
        completion(items.filter { $0.uuid == uuid }.first)
    }

    func addItem(item: MemoItem, completionHandler completion: @escaping ItemsCompletion<MemoItem>) throws {
        try updateItem(item: item) { newItems in
            completion(newItems)
        }
    }

    func updateItem(item: MemoItem, completionHandler completion: @escaping ItemsCompletion<MemoItem>) throws {
        let items = try Disk.retrieve("recordings.json", from: .documents, as: [MemoItem].self)
        var newItems = items
        if let existingIndex = newItems.index(where: { $0.uuid == item.uuid }) {
            newItems[existingIndex] = item
        } else {
            var newItem = MemoItem(uuid: item.uuid, text: item.text, createdAt: item.createdAt, sentiment: item.sentiment, fileURL: nil)
            let workingFile = try AKAudioFile(writeIn: .documents, name: "\(item.uuid).m4a")
            newItem.fileURL = workingFile.url
            newItems.append(newItem)
        }
        completion(newItems)
    }

    func deleteItem(item: MemoItem, completionHandler completion: @escaping ItemsCompletion<MemoItem>) throws {
        let items = try Disk.retrieve("recordings.json", from: .documents, as: [MemoItem].self)
        let newItems = items
            .filter { $0.uuid != item.uuid }
        try Disk.save(newItems, to: .documents, as: "recordings.json")
        if let fileURL = item.fileURL {
            try Disk.remove(fileURL.lastPathComponent, from: .documents)
        }
        completion(newItems)
    }
}

