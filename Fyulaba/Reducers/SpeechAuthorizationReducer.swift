//
//  SpeechAuthorizationReducer.swift
//  Fyulaba
//
//  Created by Etem Serkan Sökmen on 25/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import Speech

struct SpeechAuthorizationReducer: Reducer {
    func handleAction(action: Action, state: SpeechAuthorizationState?) -> SpeechAuthorizationState {
        
        var state = state ?? .none
        
        switch action {
        case _ as RequestSpeechAuthorization:
            
            SFSpeechRecognizer.requestAuthorization { (authStatus) in
                
                switch authStatus {
                    
                case .authorized:
                    state = .authorized
                    
                case .denied:
                    state = .denied("User denied access to speech recognition")
                    
                case .restricted:
                    state = .denied("Speech recognition restricted on this device")
                    
                case .notDetermined:
                    state = .denied("Speech recognition not yet authorized")
                }
                
                OperationQueue.main.addOperation {
                    
                    // here you can perform UI action, e.g. enable or disable a record button
                    switch state {
                    case .authorized:
                        store.dispatch(SetSpeechAuthorized())
                    case let .denied(message):
                        store.dispatch(SetSpeechAuthorizationError(message: message))
                    case .none:
                        break
                    }
                }
            }
            
        case let action as SetSpeechAuthorizationError:
            return .denied(action.message)
        
        default:
            return state
        }
        
        return state
    }
}
