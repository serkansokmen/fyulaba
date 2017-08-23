//
//  AppReducer.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift

struct AppReducer: Reducer {

    let persistanceManager = MemoManager()

    func handleAction(action: Action, state: AppState?) -> AppState {
        return AppState(
            memoItems: MemoItemsReducer(with: self.persistanceManager)
                .handleAction(action: action, state: state?.memoItems)
        )
    }
    
}
