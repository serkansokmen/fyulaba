//
//  MemoProcessingReducer.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import Speech
import AudioKit

struct MemoRecorderReducer: Reducer {

    func handleAction(action: Action, state: MemoRecorderState?) -> MemoRecorderState {
        
        var state = state ?? MemoRecorderState()
        
        switch action {
            
        case _ as RequestAuthorization:
            
            SFSpeechRecognizer.requestAuthorization { (authStatus) in
                
                switch authStatus {
                    
                case .authorized:
                    state.authorizationState = .authorized
                    
                case .denied:
                    state.authorizationState = .denied("User denied access to speech recognition")
                    
                case .restricted:
                     state.authorizationState = .denied("Speech recognition restricted on this device")
                    
                case .notDetermined:
                    state.authorizationState = .denied("Speech recognition not yet authorized")
                }
                
                OperationQueue.main.addOperation {
                    
                    // here you can perform UI action, e.g. enable or disable a record button
                    switch state.authorizationState {
                    case .authorized:
                        store.dispatch(SetAudioState(state: .ready(nil)))
                    case let .denied(message):
                        store.dispatch(RequestAuthorizationError(reason: message))
                    case .none:
                        break
                    }
                }
            }
            
        case let action as RequestAuthorizationError:
            state.authorizationState = .denied(action.reason)
            return state
            
        case let action as SetAudioState:
            
            switch action.state {
            case .none:
                return state
            
            case .ready:
                AKSettings.bufferLength = .medium
                do {
                    try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
                } catch {
                    AKLog("Could not set session category.")
                }
                AKSettings.defaultToSpeaker = true
                
                state.micMixer = AKMixer(state.mic)
                state.micBooster = AKBooster(state.micMixer)
                state.micBooster?.gain = 0
                state.recorder = try? AKNodeRecorder(node: state.micMixer)
                if let file = state.recorder?.audioFile {
                    state.player = try? AKAudioPlayer(file: file)
                    state.player?.looping = true
                    state.player?.completionHandler = {
                        DispatchQueue.main.async {
                            store.dispatch(SetAudioState(state: .playbackCompleted(state.player)))
                        }
                    }
                    state.variSpeed = AKVariSpeed(state.player)
                    state.variSpeed?.rate = 1.0
                    state.mainMixer = AKMixer(state.variSpeed, state.micBooster)
                    AudioKit.output = state.mainMixer
                    AudioKit.start()
                }
                
            case .recording:
                return state
            
            case .playing:
                break
                
            case .playbackCompleted(_):
                print("Playback completed")
                break
                
            case let .error(error):
                print(error.localizedDescription)
                
            }
            
            
        default:
            break
        }

        return state
    }

}
