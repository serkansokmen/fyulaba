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

func setupWorkingAudioFile(_ memo: MemoItem?, completion completionHandler: ((AKAudioFile?) -> Void)?) {
    var file: AKAudioFile?
    if let workingFileURL = memo?.fileURL {
        file = try? AKAudioFile(readFileName: workingFileURL.absoluteString)
    } else {
        file = try? AKAudioFile()
    }
    MemoRecorder.shared.setup(with: file, completion: completionHandler)
}

func stopRecording(completion completionHandler: ((AKAudioFile) -> Void)?) {
    MemoRecorder.shared.stopRecording(completion: completionHandler)
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


