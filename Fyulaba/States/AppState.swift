//
//  AppState.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 23/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import ReSwiftRouter

// States
struct AppState: StateType {
    var routingState: RoutingState
    let memoItems: MemoItemsState
    let speechAuthorization: SpeechAuthorizationState
    let memoRecorder: MemoRecorderState
}
