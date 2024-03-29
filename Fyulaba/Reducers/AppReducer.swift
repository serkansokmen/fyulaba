//
//  AppReducer.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import ReSwiftRouter

struct AppReducer: Reducer {

    func handleAction(action: Action, state: AppState?) -> AppState {
        return
            AppState(
                routingState: RoutingReducer().handleAction(action: action, state: state?.routingState),
                memoItems: MemoItemsReducer().handleAction(action: action, state: state?.memoItems),
                memoRecorder: MemoRecorderReducer().handleAction(action: action, state: state?.memoRecorder)
            )
    }
}
