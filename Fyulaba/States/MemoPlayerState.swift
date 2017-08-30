//
//  MemoDetailState.swift
//  Fyulaba
//
//  Created by Etem Serkan Sökmen on 30/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import AudioKit

struct MemoPlayerState: StateType {
    
    var memo: MemoItem?
    var player: AKAudioPlayer?
    var mainMixer: AKMixer?
    
    init() {
        self.memo = nil
    }
    
    init(with memo: MemoItem?) {
        self.memo = memo
    }
}

