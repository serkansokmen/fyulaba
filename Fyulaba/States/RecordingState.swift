//
//  AppState.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 22/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter

struct RecordingState: StateType {
    var recordings: Response<[Recording]>
}
