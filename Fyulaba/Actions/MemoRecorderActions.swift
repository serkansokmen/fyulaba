//
//  MemoProcessingActions.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift

struct RequestAuthorization: Action { }
struct RequestAuthorizationError: Action {
    let reason: String
}
struct SetAudioState: Action {
    let state: MemoAudioStateType
}
