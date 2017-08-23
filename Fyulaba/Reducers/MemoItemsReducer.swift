//
//  MemoItemsReducer.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift

struct MemoItemsReducer: Reducer {

    let api: MemoManager

    func handleAction(action: Action, state: MemoItemsState?) -> MemoItemsState {

        switch action {
        case let action as FetchMemoListAction:
            fetchMemoItems(query: action.query)
            break
        default:
            break
        }

//        switch state {
//        case .loading:
//            state.items = .none
//        case .success(items):
//            state.items = items
//        }

        return state ?? .none
    }

    init(with manager: MemoManager) {
        self.api = manager
    }

    func fetchMemoItems(query: String?) {
        do {
            try api.getItems(query: query) { items in
                print(items)
                DispatchQueue.main.async {
                    store.dispatch(SetMemoItemsAction(items: items))
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
