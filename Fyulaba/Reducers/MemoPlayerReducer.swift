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
            
            let timePitch = AKTimePitch(state.player)
            timePitch.rate = 2.0
            timePitch.pitch = -400.0
            timePitch.overlap = 8.0
            state.timePitch = timePitch
            
            state.mainMixer = AKMixer(state.timePitch)
            AudioKit.output = state.mainMixer
            
            do {
                try AudioKit.start()
            } catch let err {
                print(err.localizedDescription)
            }
        
        case _ as SetPlayerPlaying:
            state.player?.start()
        
        case _ as SetPlayerPaused:
            state.player?.pause()
        
        case _ as SetPlayerStopped:
            state.player?.stop()
        
        case let action as SetSpeedRate:
            state.timePitch?.rate = action.value
        
        case let action as SetSpeedPitch:
            state.timePitch?.pitch = action.value
        
        case let action as SetSpeedOverlap:
            state.timePitch?.overlap = action.value
            
        default:
            return state
        }
        
        return state
    }
}
