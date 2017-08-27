//
//  RoutingReducer.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift

//func routingReducer(action: Action, state: RoutingState?) -> RoutingState {
//    let state = state ?? RoutingState()
//    return state
//}

struct RoutingReducer: Reducer {

    func handleAction(action: Action, state: RoutingState?) -> RoutingState {

        var state = state ?? RoutingState()

        switch action {
        case let action as RoutingAction:
            state.destination = action.destination
        default: break
        }

        return state
    }
}
