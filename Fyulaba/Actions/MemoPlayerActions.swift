//
//  MemoProcessingActions.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import Speech
import AudioKit
import Disk

struct SetupAudioPlayer: Action {
    let memo: MemoItem
}
struct StartPlaying: Action { }
struct PausePlaying: Action { }
struct StopPlaying: Action { }
struct SetMemoPlayerError: Action {
    let error: Error?
}

