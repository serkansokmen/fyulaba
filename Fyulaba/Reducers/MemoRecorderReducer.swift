//
//  MemoProcessingReducer.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import AudioKit


struct MemoRecorderReducer: Reducer {
    
    func handleAction(action: Action, state: MemoRecorderState?) -> MemoRecorderState {
        
        var state = state ?? MemoRecorderState(memo: nil,
                                               recordingState: .none,
                                               audioNode: nil,
                                               transcriptionResult: "",
                                               sentiment: nil,
                                               features: [:],
                                               isTranscribing: false)
        
        switch action {
            
        case let action as SetMemoRecorderReady:
            state.recordingState = .ready
            state.memo = action.item ?? state.memo
            state.audioNode = MemoRecorder.shared.mic
            
        case let action as SelectMemoItem:
            state.memo = action.item ?? state.memo
            
        case _ as SetMemoRecorderStartRecording:
            try? MemoRecorder.shared.startRecording()
            state.recordingState = .recording
            state.audioNode = MemoRecorder.shared.mic
        
        case _ as SetMemoRecorderCompletedRecording:
            state.audioNode = nil
            state.recordingState = .paused
            state.audioNode = MemoRecorder.shared.mic
        
        case _ as SetMemoRecorderStartPlaying:
            MemoRecorder.shared.startPlaying()
            state.recordingState = .playing
            state.audioNode = MemoRecorder.shared.player
        
        case _ as SetMemoRecorderStopPlaying:
            MemoRecorder.shared.stopPlaying()
            state.recordingState = .paused
            state.audioNode = MemoRecorder.shared.mic
        
        case _ as ResetMemoRecorder:
            MemoRecorder.shared.reset()
            state.recordingState = .ready
            state.audioNode = MemoRecorder.shared.mic
            
        case let action as SetMemoRecorderError:
            state.recordingState = .error(action.error)
            state.audioNode = MemoRecorder.shared.mic
            state.isTranscribing = false
        
        case let action as SetTranscriptionResult:
            state.transcriptionResult = action.result ?? ""
            state.sentiment = action.sentiment
            state.features = action.features
            state.isTranscribing = false
            
        case _ as ResetTranscriptionResult:
            state.transcriptionResult = ""
            state.sentiment = nil
            state.features = [:]
            state.isTranscribing = false
            
        case _ as SetTranscriptionInProgress:
            state.isTranscribing = true
        
        case _ as SetTranscriptionError:
            state.transcriptionResult = ""
            state.sentiment = nil
            state.features = [:]
            state.isTranscribing = false
        
        case let action as RemoveFeatureTag:
            state.features = state.features.filter { $0.key != action.title }
        
        case _ as StartAudioEngine:
            MemoRecorder.shared.startAudioEngine()
        
        case _ as StopAudioEngine:
            MemoRecorder.shared.stopAudioEngine()
            
            
        default:
            return state
        }
        
        return state
    }

}
