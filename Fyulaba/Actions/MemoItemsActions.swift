//
//  MemoItemActions.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift


func fetchMemoItems(query: String?) -> Store<AppState>.ActionCreator {
    return { state, store in
        do {
            try api.getItems(query: query ?? "") { items in
                store.dispatch(SetMemoItems(items: items))
            }
        } catch let error {
            store.dispatch(ErrorMemoItems(error: error))
        }
        return SetLoading()
    }
}

func fetchMemoItem(_ uuid: String) -> Store<AppState>.ActionCreator {
    return { state, store in
        do {
            try api.getItem(uuid: uuid) { item in
                guard let item = item else { return }
                DispatchQueue.main.async {
                    store.dispatch(SelectMemoItem(item: item))
                    store.dispatch(ResetRecording())
                    store.dispatch(SetupAudioPlayer(memo: item))
                    store.dispatch(RoutingAction(destination: .memoPlayer))
                }
            }
        } catch let error {
            store.dispatch(ErrorMemoItems(error: error))
        }
        return SetLoading()
    }
}

func deleteMemoItem(_ item: MemoItem) -> Store<AppState>.ActionCreator {
    return { state, store in
        do {
            try MemoManager.shared.deleteItem(item: item) { items in
                store.dispatch(SetMemoItems(items: items))
            }
        } catch let error {
            store.dispatch(ErrorMemoItems(error: error))
        }
        return SetLoading()
    }
}

struct SetLoading: Action { }

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
