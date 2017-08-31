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

func requestSpeechAuthorization() -> Store<AppState>.ActionCreator {
    
    return { state, store in
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isAuthorized = false
            var message = ""
            switch authStatus {
                
            case .authorized:
                isAuthorized = true
                
            case .denied:
                isAuthorized = false
                message = "User denied access to speech recognition"
                
            case .restricted:
                isAuthorized = false
                message = "Speech recognition restricted on this device"
                
            case .notDetermined:
                isAuthorized = false
                message = "Speech recognition not yet authorized"
            }
            
            if isAuthorized {
                OperationQueue.main.addOperation {
                    store.dispatch(SetupAudioRecorder(memo: MemoItem()))
                }
            } else {
                OperationQueue.main.addOperation {
                    store.dispatch(SetRequestError(message: message))
                }
            }
        }
        return ResetRecording()
    }
}

struct SetupAudioRecorder: Action {
    let memo: MemoItem?
}
struct RequestingAuthorization: Action { }
struct SetRequestError: Action {
    let message: String?
}

struct StartRecording: Action { }
struct PauseRecording: Action { }
struct ResetRecording: Action { }
struct SetRecorderPlaying: Action { }
struct SetRecorderStopped: Action { }

struct ExportedRecording: Action {
    let exportedFile: AKAudioFile
}
struct SetMemoRecorderError: Action {
    let error: Error?
}
struct TranscribeMemoItem: Action { }
struct SetTranscriptionError: Action {
    let error: Error?
}
struct SetTranscriptionResult: Action {
    let result: String?
    let sentiment: SentimentType?
    let features: [TranscriptionFeature]
}
struct RemoveFeatureTag: Action {
    let title: String
}
struct SaveAndDismissRecording: Action { }

