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

public enum Response<T> {
    case loading
    case success(T)
    case failure(Error)
}

struct AppReducer: Reducer {

    func handleAction(action: Action, state: State?) -> State {

        return State(
            navigationState: NavigationReducer.handleAction(action, state: state?.navigationState),
            recordingState: RecordingReducer().handleAction(action: action, state: state?.recordingState)
        )
    }
}
