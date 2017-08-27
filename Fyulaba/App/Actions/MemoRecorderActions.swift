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

func setupWorkingAudioFile(_ file: AKAudioFile?, completion completionHandler: ((AKAudioFile?) -> Void)?) {
    MemoRecorder.shared.setup(with: file, completion: completionHandler)
}

struct SetMemoRecorderReady: Action {
    let workingFile: AKAudioFile?
}
struct SetMemoRecorderStartRecording: Action { }
struct SetMemoRecorderStopRecording: Action { }
struct SetMemoRecorderStartPlaying: Action { }
struct SetMemoRecorderStopPlaying: Action { }
struct SetMemoRecorderError: Action {
    let error: Error?
}
struct ResetMemoRecorder: Action { }

