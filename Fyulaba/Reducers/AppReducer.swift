//
//  AppReducer.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import ReSwiftRouter

func appReducer(action: Action, state: AppState?) -> AppState {
    return
        AppState(
            routingState: routingReducer(action: action, state: state?.routingState),
            memoItems: memoItemsReducer(action: action, state: state?.memoItems),
            memoRecorder: memoRecorderReducer(action: action, state: state?.memoRecorder),
            memoPlayer: memoPlayerReducer(action: action, state: state?.memoPlayer)
    )
}
