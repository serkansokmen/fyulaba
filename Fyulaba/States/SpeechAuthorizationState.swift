//
//  SpeechAuthorizationState.swift
//  Fyulaba
//
//  Created by Etem Serkan Sökmen on 25/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift

enum SpeechAuthorizationState: StateType {
    case none
    case authorized
    case denied(String)
}
