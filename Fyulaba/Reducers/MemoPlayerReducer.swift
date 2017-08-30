//
//  MemoPlayerReducer.swift
//  Fyulaba
//
//  Created by Etem Serkan Sökmen on 30/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import AudioKit

struct MemoPlayerReducer: Reducer {
    
    private var selectedMemo: MemoItem?
    
    init(with memo: MemoItem?) {
        self.selectedMemo = memo
    }
    
    func handleAction(action: Action, state: MemoPlayerState?) -> MemoPlayerState {
        
        var state = state ?? MemoPlayerState(with: self.selectedMemo)
        
        switch action {
        
        case let action as SetupAudioPlayer:
            
            AKSettings.bufferLength = .medium
            
            do {
                try AKSettings.setSession(category: .playback, with: .duckOthers)
            } catch {
                AKLog("Could not set session category.")
                return state
            }
            AKSettings.defaultToSpeaker = true
            
            state.memo = action.memo
            state.player = try? AKAudioPlayer(file: state.memo!.file)
            state.player?.looping = true
//            state.variSpeed = AKVariSpeed(state.player)
//            state.variSpeed?.rate = 1.0
            state.mainMixer = AKMixer(state.player)
            AudioKit.output = state.mainMixer
            AudioKit.start()
            state.memo = action.memo
        
        case _ as StartPlaying:
            state.player?.start()
        
        case _ as PausePlaying:
            state.player?.pause()
        
        case _ as StopPlaying:
            state.player?.stop()
            
        default:
            return state
        }
        
        return state
    }
}
