//
//  MemoProcessingReducer.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import AudioKit
import Disk

struct MemoRecorderReducer: Reducer {
    
    func handleAction(action: Action, state: MemoRecorderState?) -> MemoRecorderState {
        
        var state = state ?? MemoRecorderState(with: MemoItem())
        
        switch action {
        
        case _ as RequestingAuthorization:
            return state
        
        case _ as SetRequestError:
            return state
        
        case _ as ResetRecording:
            state.player?.stop()
            do {
                try state.recorder?.reset()
            } catch let err {
                print(err.localizedDescription)
            }
            state.recordingState = .ready
//            if let fileName = state.memo?.file.fileNamePlusExtension,
//                Disk.exists(fileName, in: .documents) {
//                try? Disk.remove(fileName, from: .documents)
//            }
            state.memo = nil
            AudioKit.stop()
            
        case let action as SetupAudioRecorder:
            
            if let recorder = state.recorder,
                recorder.isRecording {
                state.player?.stop()
                do {
                    try state.recorder?.reset()
                } catch let err {
                    print(err.localizedDescription)
                }
                state.recordingState = .ready
                if let fileName = state.memo?.file.fileNamePlusExtension,
                    Disk.exists(fileName, in: .documents) {
                    try? Disk.remove(fileName, from: .documents)
                }
                state.memo = nil
            }
            
            AKSettings.bufferLength = .medium
            
            do {
                try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
            } catch {
                AKLog("Could not set session category.")
                return state
            }
            AKSettings.defaultToSpeaker = true
            
            state.memo = action.memo ?? MemoItem()
            state.mic = AKMicrophone()
            state.micMixer = AKMixer(state.mic)
            state.micBooster = AKBooster(state.micMixer)
            state.micBooster?.gain = 0
            
            state.recorder = try? AKNodeRecorder(node: state.micMixer,
                                                 file: state.memo!.file)
            state.player = try? AKAudioPlayer(file: state.memo!.file)
            
            state.recorder?.durationToRecord = 60.0
            state.player?.looping = true
            state.variSpeed = AKVariSpeed(state.player)
            state.variSpeed?.rate = 1.0
            state.mainMixer = AKMixer(state.variSpeed, state.micBooster)
            AudioKit.output = state.mainMixer
            AudioKit.start()
            
            state.recordingState = .ready
        
        case _ as StartRecording:
            if AKSettings.headPhonesPlugged {
                state.micBooster?.gain = 1
            }
            do {
                try state.recorder?.record()
            } catch let error {
                print(error.localizedDescription)
            }
            state.currentNode = state.mic
            state.recordingState = .recording
        
        case _ as PauseRecording:
            state.micBooster?.gain = 0
            do {
                try state.player?.reloadFile()
            } catch let err {
                print(err.localizedDescription)
            }
            let recordedDuration = state.player != nil ? state.player!.audioFile.duration  : 0
            if recordedDuration > 0.0 {
                state.recorder?.stop()
                
                guard let file = state.memo?.file else { return state }
                state.player?.audioFile.exportAsynchronously(name: file.fileName,
                                                             baseDir: .documents,
                                                             exportFormat: .m4a) { file, exportError in
                                                                if let error = exportError {
                                                                    print(error.localizedDescription)
                                                                } else {
                                                                    if let file = file {
                                                                        print("Export succeeded \(file.url)")
                                                                        DispatchQueue.main.async {
                                                                            store.dispatch(ExportedRecording(exportedFile: file))
                                                                        }
                                                                    }
                                                                }
                }
                state.currentNode = state.player
            }
        
        case let action as ExportedRecording:
            state.memo?.file = action.exportedFile
            state.recordingState = .paused
        
        case _ as StartPlaying:
            state.player?.play()
            state.recordingState = .playing
        
        case _ as StopPlaying:
            state.player?.stop()
            state.recordingState = .paused
        
        case let action as SetMemoRecorderError:
            state.recordingState = .error(action.error)
            state.isTranscribing = false
        
        case _ as TranscribeMemoItem:
            guard let memo = state.memo else { return state }
            SpeechTranscriber.shared.recognizeSpeechFromAudioFile(memo.file.url, result: { result, sentiment, features in
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
            state.isTranscribing = true
            
        case let action as SetTranscriptionResult:
            state.memo?.text = action.result ?? ""
            state.memo?.sentiment = action.sentiment
            state.memo?.features = action.features
            state.isTranscribing = false
        
        case _ as SetTranscriptionError:
            state.memo?.text = ""
            state.memo?.sentiment = nil
            state.memo?.features = []
            state.isTranscribing = false
        
        case let action as RemoveFeatureTag:
            let filteredItems = state.memo?.features.filter { $0.key != action.title }
            state.memo?.features = filteredItems ?? []
        
        case _ as SaveAndDismissRecording:
            guard let memo = state.memo else { return state }
            try? MemoManager.shared.addItem(item: memo) { items in
                DispatchQueue.main.async {
                    store.dispatch(SetMemoItems(items: items))
                    store.dispatch(RoutingAction(destination: .root))
                }
            }
        
        default:
            return state
        }
        
        return state
    }

}
