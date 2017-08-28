//
//  SpeechRecordingState.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import AudioKit

enum MemoRecorderRecordingState: StateType {
    case none
    case initialising
    case ready
    case recording
    case playing
    case paused
    case error(Error?)
}

struct MemoRecorderState: StateType {
    var memo: MemoItem
    var recordingState: MemoRecorderRecordingState
    var audioNode: AKNode?
    var transcriptionResult: String
    var sentiment: SentimentType
    var features: [String:Double]
    var isTranscribing: Bool
}
