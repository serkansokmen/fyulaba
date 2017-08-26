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
struct SetupMemoRecorderSuccess: Action { }
struct StartAudioEngine: Action { }
struct StopAudioEngine: Action { }
struct SetMemoRecorderStartRecording: Action { }
struct SetMemoRecorderStopRecording: Action { }
struct SetMemoRecorderStartPlaying: Action { }
struct SetMemoRecorderStopPlaying: Action { }
struct SetMemoRecorderError: Action {
    let error: Error?
}
struct ResetMemoRecorder: Action { }
struct DoneMemoRecorder: Action { }
