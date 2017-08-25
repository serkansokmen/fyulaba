//
//  MemoProcessingActions.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import AudioKit

struct SetupMemoRecorder: Action {
    let file: AKAudioFile?
}

struct SetupMemoRecorderSuccess: Action {
    let file: AKAudioFile?
}

struct SetMemoRecorderRecording: Action { }

struct SetMemoRecorderPlaying: Action { }

struct SetMemoRecorderError: Action {
    let error: Error?
}
