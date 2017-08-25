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

        let state = state ?? .none

        switch action {
        case _ as FetchMemoListingAction:

            switch state {

            case .none:
                do {
                    try api.getItems(query: "") { items in return
                        DispatchQueue.main.async {
                            store.dispatch(SetMemoItemsAction(items: items))
                        }
                    }
                } catch let error {
                    return .error(error)
                }
                break

            default: break
            }

        default:
            break
        }

        return state
    }

    init(with manager: MemoManager) {
        self.api = manager
    }
}
