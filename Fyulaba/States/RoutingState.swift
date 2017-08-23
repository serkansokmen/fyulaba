//
//  RoutingState.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift

struct RoutingState: StateType {
    var navigationState: RoutingDestination

    init(navigationState: RoutingDestination = .root) {
        self.navigationState = navigationState
    }
}
