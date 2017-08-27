//
//  MemoItemActions.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift

func fetchMemoItems(query: String?) {
    do {
        try api.getItems(query: query ?? "") { items in
            DispatchQueue.main.async {
                store.dispatch(SetMemoItems(items: items))
            }
        }
    } catch let error {
        DispatchQueue.main.async {
            store.dispatch(ErrorMemoItems(error: error))
        }
    }
}

func fetchMemoItem(_ uuid: String) {
    do {
        try api.getItem(uuid: uuid) { item in
            DispatchQueue.main.async {
                store.dispatch(SelectMemoItem(item: item))
            }
        }
    } catch let error {
        DispatchQueue.main.async {
            store.dispatch(ErrorMemoItems(error: error))
        }
    }
}

struct SetMemoItems: Action {
    let items: [MemoItem]
}

struct SelectMemoItem: Action {
    let item: MemoItem?
}

struct AddMemoItem: Action {
    let newItem: MemoItem
}

struct UpdateMemoItem: Action {
    let updatedItem: MemoItem
}

struct DeleteMemoItem: Action {
    let item: MemoItem
}

struct ErrorMemoItems: Action {
    let error: Error?
}
