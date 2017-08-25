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
                    store.dispatch(SetupMemoRecorderSuccess(file: action.file))
                }
            }
            return .initialising
        
        case let action as SetupMemoRecorderSuccess:
            return .ready(action.file)
        
        case _ as SetMemoRecorderRecording:
            return .recording
        
        case _ as SetMemoRecorderPlaying:
            return .playing
            
        case let action as SetMemoRecorderError:
            return .error(action.error)
            
        default:
            return .none
        }
    }

}
