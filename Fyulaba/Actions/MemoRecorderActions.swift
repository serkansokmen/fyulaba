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

func setupWorkingAudioFile(_ memo: MemoItem?) {
    var file: AKAudioFile?
    if let workingFileURL = memo?.fileURL {
        file = try? AKAudioFile(readFileName: workingFileURL.absoluteString)
    } else {
        file = try? AKAudioFile()
    }
    MemoRecorder.shared.setup(with: file) { workingFile in
        DispatchQueue.main.async {
            store.dispatch(SetMemoRecorderReady(workingFile: workingFile))
        }
    }
}

func stopRecording() {
    MemoRecorder.shared.stopRecording { file in
        DispatchQueue.main.async {
            store.dispatch(SetMemoRecorderCompletedRecording(workingFile: file))
        }
    }
}

func transcribeAudioFile(_ file: AKAudioFile) {
    SpeechTranscriber.shared.recognizeSpeechFromAudioFile(file.url, result: { result, sentiment, features in
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
    let workingFile: AKAudioFile?
}

struct SetMemoRecorderStartRecording: Action { }
struct SetMemoRecorderCompletedRecording: Action {
    let workingFile: AKAudioFile?
}
struct SetMemoRecorderStartPlaying: Action { }
struct SetMemoRecorderStopPlaying: Action { }
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
    let features: [String:Double]
}
struct ResetTranscriptionResult: Action { }

struct RemoveFeatureTag: Action {
    let title: String
}
