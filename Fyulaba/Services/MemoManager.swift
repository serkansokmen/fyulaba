//
//  MemoManager.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import Disk

struct MemoManager: PersistanceManager  {

    func getItems(query: String?, completionHandler completion: @escaping ItemsCompletion<MemoItem>) throws {
        let items = try Disk.retrieve("recordings.json",
                                      from: .documents,
                                      as: [MemoItem].self)
        completion(items)
    }
}
