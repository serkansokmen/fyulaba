//
//  RoutingActions.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import ReSwift

struct RoutingAction: Action {
    static let identifier = "ROUTING_ACTION"
    let destination: RoutingDestination
}
