//
//  MemoItemActions.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift

struct FetchMemoListingAction: Action { }

struct SetMemoItemsAction: Action {
    let items: [MemoItem]
}

struct FetchMemoItemAction: Action {
    let uuid: String
}

struct AddMemoAction: Action {
    let newItem: MemoItem
}

struct UpdateMemoAction: Action {
    let updatedItem: MemoItem
}

struct DeleteMemoAction: Action {
    let item: MemoItem
}
