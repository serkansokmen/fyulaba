//
//  MemoItemsReducer.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift

struct MemoItemsReducer: Reducer {

    func handleAction(action: Action, state: MemoItemsState?) -> MemoItemsState {
        
        let state = state ?? MemoItemsState(items: [], selectedItem: nil)
        
        switch action {
            
        case let action as SetMemoItems:
            return MemoItemsState(items: action.items, selectedItem: nil)
        
        case let action as SelectMemoItem:
            return MemoItemsState(items: state.items, selectedItem: action.item)
        
        case let action as AddMemoItem:
            return MemoItemsState(items: state.items + [action.newItem], selectedItem: action.newItem)
        
        default:
            return state
            
        }
    }
}
