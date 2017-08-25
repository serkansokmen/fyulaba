//
//  MemoProcessingReducer.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift
import AudioKit

struct MemoProcessingReducer: Reducer {

    func handleAction(action: Action, state: MemoProcessingState?) -> MemoProcessingState {
        
        guard let state = state else { return MemoProcessingState() }
        
        switch action {
        case _ as SetupAudio:

            // Session settings
            AKSettings.bufferLength = .medium
            do {
                try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
            } catch {
                AKLog("Could not set session category.")
            }

            AKSettings.defaultToSpeaker = true

            // Patching
//            state.micMixer = AKMixer(state.mic)
//            state.micBooster = AKBooster(state.micMixer)
//
//            // Will set the level of microphone monitoring
//            state.micBooster?.gain = 0
//
//            state.recorder
//            if let recording = self.recording {
//                if let fileURL = recording.fileURL,
//                    Disk.exists(fileURL.lastPathComponent, in: .documents) {
//                    do {
//                        let workingFile = try AKAudioFile(readFileName: fileURL.lastPathComponent, baseDir: .documents)
//                        do {
//                            self.recorder = try AKNodeRecorder(node: self.micMixer, file: workingFile)
//                        } catch let error {
//                            self.recorder = try AKNodeRecorder(node: self.micMixer)
//                            self.showAlert(error.localizedDescription, type: .error)
//                        }
//                    } catch let error {
//                        self.recorder = try? AKNodeRecorder(node: self.micMixer)
//                        self.showAlert(error.localizedDescription, type: .error)
//                    }
//                } else {
//                    self.recorder = try? AKNodeRecorder(node: self.micMixer)
//                }
//            } else {
//                self.recorder = try? AKNodeRecorder(node: self.micMixer)
//            }
//
//            if let file = recorder.audioFile {
//                player = try? AKAudioPlayer(file: file)
//                player.looping = true
//                player.completionHandler = playingEnded
//            }
//
//            variSpeed = AKVariSpeed(player)
//            variSpeed.rate = 1.0
//
//            mainMixer = AKMixer(variSpeed, micBooster)
//
//            AudioKit.output = mainMixer

        default:
            break
        }

        return state
    }

}
