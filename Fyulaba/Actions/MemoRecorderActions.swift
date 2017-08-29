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

func requestAuthorization(completion completionHandler: (() -> Void)?, denied deniedHandler: ((String)->Void)?) {
    
    SFSpeechRecognizer.requestAuthorization { (authStatus) in
        
        switch authStatus {
            
        case .authorized:
            completionHandler?()
            
        case .denied:
            deniedHandler?("User denied access to speech recognition")
            
        case .restricted:
            deniedHandler?("Speech recognition restricted on this device")
            
        case .notDetermined:
            deniedHandler?("Speech recognition not yet authorized")
        }
        
    }
}

struct SetupAudio: Action {
    let memo: MemoItem
}

func transcribe(item: MemoItem) {
    SpeechTranscriber.shared.recognizeSpeechFromAudioFile(item.file.url, result: { result, sentiment, features in
        DispatchQueue.main.async {
            store.dispatch(SetTranscriptionResult(result: result,
                                                  sentiment: sentiment,
                                                  features: features))
        }
    }, error: { error in
        DispatchQueue.main.async {
            store.dispatch(SetTranscriptionError(error: error))
        }
    })
    DispatchQueue.main.async {
        store.dispatch(SetTranscriptionInProgress())
    }
}

func persistMemoItemAndDismiss(_ item: MemoItem) {
    try? MemoManager.shared.addItem(item: item) { items in
        DispatchQueue.main.async {
            store.dispatch(SetMemoItems(items: items))
            store.dispatch(RoutingAction(destination: .root))
        }
    }
}

struct SetMemoRecorderReady: Action {
    let item: MemoItem?
}

struct StartRecording: Action { }
struct PauseRecording: Action { }
struct ExportedRecording: Action {
    let exportedFile: AKAudioFile
}
struct StartPlaying: Action { }
struct StopPlaying: Action { }
struct SetMemoRecorderError: Action {
    let error: Error?
}
struct ResetMemoRecorder: Action { }

struct SetTranscriptionInProgress: Action { }
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

