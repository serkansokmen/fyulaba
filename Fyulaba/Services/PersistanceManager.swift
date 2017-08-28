//
//  PersistanceManager.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation

typealias ItemsCompletion<T> = (([T]) -> Void)?
typealias ItemCompletion<T> = ((T?) -> Void)?

protocol PersistanceManager {
    associatedtype T

    func getItems(query: String?, completion completionHandler: ItemsCompletion<T>) throws

    func getItem(uuid: String, completion completionHandler: ItemCompletion<T>) throws

    func addItem(item: T, completion completionHandler: ItemsCompletion<T>) throws

    func updateItem(item: T, completion completionHandler: ItemsCompletion<T>) throws

    func deleteItem(item: T, completion completionHandler: ItemsCompletion<T>) throws
}
