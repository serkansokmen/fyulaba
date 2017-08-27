//
//  SpeechRecordingState.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import AudioKit

enum MemoRecorderState: StateType {
    case none
    case initialising
    case ready(AKAudioFile?)
    case recording
    case playing
    case stopped
    case error(Error?)
}
