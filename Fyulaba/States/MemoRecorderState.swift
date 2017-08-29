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
    var memo: MemoItem?
    var recordingState: MemoRecorderRecordingState = .none
    var isTranscribing: Bool = false
    var recorder: AKNodeRecorder?
    var mic: AKMicrophone?
    var micBooster: AKBooster?
    var micMixer: AKMixer?
    var player: AKAudioPlayer?
    var variSpeed: AKVariSpeed?
    var mainMixer: AKMixer?
    var currentNode: AKNode?
    
    init(with memo: MemoItem) {
        self.memo = memo
    }
}
