//
//  RequestAuthorizationActions.swift
//  Fyulaba
//
//  Created by Etem Serkan Sökmen on 25/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift

struct RequestSpeechAuthorization: Action { }

struct SetSpeechAuthorizationError: Action {
    let message: String
}

struct SetSpeechAuthorized: Action { }
