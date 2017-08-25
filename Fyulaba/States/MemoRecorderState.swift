//
//  SpeechRecordingState.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import AudioKit

enum RequestAuthorizationState: StateType {
    case none
    case authorized
    case denied(String)
}

enum MemoAudioStateType: StateType {
    case none
    case ready(AKAudioFile?)
    case recording
    case playing
    case playbackCompleted(AKAudioPlayer?)
    case error(Error)
}

struct MemoRecorderState: StateType {
    var authorizationState: RequestAuthorizationState
    var audioState: MemoAudioStateType
    var recorder: AKNodeRecorder?
    var mic: AKMicrophone?
    var micBooster: AKBooster?
    var micMixer: AKMixer?
    var player: AKAudioPlayer?
    var variSpeed: AKVariSpeed?
    var mainMixer: AKMixer?
    
    init() {
        self.authorizationState = .none
        self.audioState = .none
        self.recorder = nil
        self.mic = nil
        self.micBooster = nil
        self.micMixer = nil
        self.player = nil
        self.variSpeed = nil
        self.mainMixer = nil
    }
}
