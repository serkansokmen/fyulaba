//
//  Recordings.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 22/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter

struct AppReducer: Reducer {

    func handleAction(action: Action, state: AppState?) -> AppState {

        return AppState(
            navigationState: NavigationReducer.handleAction(action, state: state?.navigationState),
            recordings: recordingsReducer(state: state?.recordings ?? [], action: action)
        )
    }
}
