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
        
        switch action {
            
        case let action as SetupMemoRecorder:
            
            MemoRecorder.shared.setup(with: action.file) {
                DispatchQueue.main.async {
                    store.dispatch(SetupMemoRecorderSuccess())
                }
            }
            return .initialising
        
        case _ as SetupMemoRecorderSuccess:
            DispatchQueue.main.async {
                store.dispatch(StartAudioEngine())
            }
            return .initialising
        
        case _ as StartAudioEngine:
            MemoRecorder.shared.startEngine()
            return .ready(MemoRecorder.shared.workingFile)
        
        case _ as StopAudioEngine:
            MemoRecorder.shared.stopEngine()
            return .none
        
        case _ as SetMemoRecorderStartRecording:
            try? MemoRecorder.shared.startRecording()
            return .recording
        
        case _ as SetMemoRecorderStopRecording:
            MemoRecorder.shared.stopRecording { file in
                DispatchQueue.main.async {
                    store.dispatch(StartAudioEngine())
                }
            }
            return .ready(MemoRecorder.shared.workingFile)
        
        case _ as SetMemoRecorderStartPlaying:
            MemoRecorder.shared.startPlaying()
            return .playing
        
        case _ as SetMemoRecorderStopPlaying:
            MemoRecorder.shared.stopPlaying()
            return .ready(MemoRecorder.shared.workingFile)
        
        case _ as ResetMemoRecorder:
            MemoRecorder.shared.reset()
            return .ready(MemoRecorder.shared.workingFile)
        
        case _ as DoneMemoRecorder:
            MemoRecorder.shared.done  { file in
                let memo = MemoItem(uuid: UUID().uuidString, text: "", createdAt: Date(), sentiment: nil, fileURL: file.url)
                DispatchQueue.main.async {
                    store.dispatch(AddMemoAction(newItem: memo))
                    store.dispatch(RoutingAction(destination: .memoDetail))
                }
            }
            return .none
            
        case let action as SetMemoRecorderError:
            return .error(action.error)
            
        default:
            return .none
        }
    }

}
