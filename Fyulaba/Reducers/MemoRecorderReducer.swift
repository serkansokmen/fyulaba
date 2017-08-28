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
        
        var state = state ?? MemoRecorderState(memo: MemoItem(uuid: UUID().uuidString,
                                                              text: "",
                                                              createdAt: Date(),
                                                              sentiment: nil,
                                                              fileName: nil,
                                                              fileExt: nil,
                                                              fileURL: nil),
                                               recordingState: .none,
                                               audioNode: nil,
                                               transcriptionResult: "",
                                               sentiment: nil,
                                               features: [:],
                                               isTranscribing: false)
        
        switch action {
            
        case let action as SetMemoRecorderReady:
            state.recordingState = .ready
            state.memo.fileName = action.workingFile?.fileName
            state.memo.fileExt = action.workingFile?.fileExt
            state.memo.fileURL = action.workingFile?.url
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
        
        case _ as SetMemoRecorderStartPlaying:
            MemoRecorder.shared.startPlaying()
            state.recordingState = .playing
            state.audioNode = MemoRecorder.shared.player
        
        case _ as SetMemoRecorderStopPlaying:
            MemoRecorder.shared.stopPlaying()
            state.recordingState = .paused
            state.audioNode = nil
        
        case _ as ResetMemoRecorder:
            MemoRecorder.shared.reset()
            state.recordingState = .none
            state.audioNode = nil
            
        case let action as SetMemoRecorderError:
            state.recordingState = .error(action.error)
            state.audioNode = nil
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
//            print(action.error?.localizedDescription)
            state.transcriptionResult = ""
            state.sentiment = nil
            state.features = [:]
            state.isTranscribing = false
        
        case let action as RemoveFeatureTag:
            state.features = state.features.filter { $0.key != action.title }
            
        default:
            return state
        }
        
        return state
    }

}
