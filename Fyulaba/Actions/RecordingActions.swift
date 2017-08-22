//
//  RecordingsActions.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 22/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import ReSwift
import Disk

// Actions
struct FetchRecordingsAction: Action {
    let query: String?
}

struct PersistRecordingsAction: Action {
    let recordings: [Recording]
}

struct AddRecordingAction: Action {
    let newRecording: Recording
}

struct UpdateRecordingAction: Action {
    let updatedRecording: Recording
}

struct RemoveRecordingAction: Action {
    let recording: Recording
}
