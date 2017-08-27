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
            
        case let action as SetMemoRecorderReady:
            guard let memo = action.memo else { return .ready(nil) }
            guard let fileURL = memo.fileURL else { return .ready(nil) }
            guard let file = try? AKAudioFile(readFileName: fileURL.absoluteString, baseDir: .documents) else { return .ready(nil) }
            return .ready(file)
        
        case _ as SetMemoRecorderStartRecording:
            try? MemoRecorder.shared.startRecording()
            return .recording
        
        case _ as SetMemoRecorderStopRecording:
            MemoRecorder.shared.stopRecording { file in
                let memo = MemoItem(uuid: UUID().uuidString, text: "", createdAt: Date(), sentiment: nil, fileURL: file.url)
                DispatchQueue.main.async {
                    store.dispatch(AddMemoItem(newItem: memo))
                    store.dispatch(RoutingAction(destination: .memoDetail))
                }
            }
            return .stopped
        
        case _ as SetMemoRecorderStartPlaying:
            MemoRecorder.shared.startPlaying()
            return .playing
        
        case _ as SetMemoRecorderStopPlaying:
            MemoRecorder.shared.stopPlaying()
            return .stopped
        
        case _ as ResetMemoRecorder:
            MemoRecorder.shared.reset()
            return .stopped
        
        case let action as SetMemoRecorderError:
            return .error(action.error)
            
        default:
            return .none
        }
    }

}
