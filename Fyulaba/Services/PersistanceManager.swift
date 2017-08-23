//
//  PersistanceManager.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import Disk

typealias ItemsCompletion<T> = (([T]) -> Void)

protocol PersistanceManager {
    associatedtype T
    func getItems(query: String?, completionHandler completion: @escaping ItemsCompletion<T>) throws
}

