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
        if !Disk.exists(instance.fileName, in: .documents) {
            try? Disk.save([MemoItem](), to: .documents, as: instance.fileName)
        }
        return instance
    }()
    
    var fileName: String {
        return "recordings.json"
    }
    
    func getItems(query: String?, completion completionHandler: ItemsCompletion<MemoItem>) throws {
        let items = try Disk.retrieve(fileName, from: .documents, as: [MemoItem].self)
        completionHandler?(items)
    }

    func getItem(uuid: String, completion completionHandler: ItemCompletion<MemoItem>) throws {
        let items = try Disk.retrieve(fileName, from: .documents, as: [MemoItem].self)
        completionHandler?(items.filter { $0.uuid == uuid }.first)
    }

    func addItem(item: MemoItem, completion completionHandler: ItemsCompletion<MemoItem>) throws {
        try updateItem(item: item) { newItems in
            completionHandler?(newItems)
        }
    }

    func updateItem(item: MemoItem, completion completionHandler: ItemsCompletion<MemoItem>) throws {
        var items: [MemoItem] = []
        if Disk.exists(fileName, in: .documents) {
            do {
                items = try Disk.retrieve(fileName, from: .documents, as: [MemoItem].self)
            } catch let err {
                print(err.localizedDescription)
            }
        }
        if let existingIndex = items.firstIndex(of: item) {
//        if let existingIndex = items.index(where: { $0.uuid == item.uuid }) {
            items[existingIndex] = item
        } else {
            items.append(item)
        }
        try? Disk.save(items, to: .documents, as: fileName)
        completionHandler?(items)
    }

    func deleteItem(item: MemoItem, completion completionHandler: ItemsCompletion<MemoItem>) throws {
        let items = try Disk.retrieve(fileName, from: .documents, as: [MemoItem].self)
        let newItems = items
            .filter { $0.uuid != item.uuid }
        try Disk.save(newItems, to: .documents, as: fileName)
        let filePath = item.file.fileNamePlusExtension
        if Disk.exists(filePath, in: .documents) {
            try Disk.remove(filePath, from: .documents)
        }
        completionHandler?(newItems)
    }
}

