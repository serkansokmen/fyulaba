//
//  MemoRecorder.swift
//  Fyulaba
//
//  Created by Etem Serkan Sökmen on 25/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import AudioKit

class MemoRecorder {
    
    static let shared: MemoRecorder = {
        let instance = MemoRecorder()
        // setup code
        return instance
    }()
    
    var recorder: AKNodeRecorder?
    var mic: AKMicrophone?
    var micBooster: AKBooster?
    var micMixer: AKMixer?
    var player: AKAudioPlayer?
    var variSpeed: AKVariSpeed?
    var mainMixer: AKMixer?
    var currentNode: AVAudioNode?
    var currentFile: AKAudioFile?
    
    init() {
        self.recorder = nil
        self.mic = nil
        self.micBooster = nil
        self.micMixer = nil
        self.player = nil
        self.variSpeed = nil
        self.mainMixer = nil
    }
    
    func setup(with audioFile: AKAudioFile?, completion completionHandler: ((AKAudioFile?) -> Void)?) {
        
        AKSettings.bufferLength = .medium
        
        do {
            try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
        } catch {
            AKLog("Could not set session category.")
        }
        AKSettings.defaultToSpeaker = true
        
        mic = AKMicrophone()
        micMixer = AKMixer(mic)
        micBooster = AKBooster(micMixer)
        micBooster?.gain = 0
        
        if let file = audioFile {
            recorder = try? AKNodeRecorder(node: micMixer, file: file)
        } else {
            recorder = try? AKNodeRecorder(node: micMixer)
        }
        recorder?.durationToRecord = 60.0
        
        if let file = recorder?.audioFile {
            player = try? AKAudioPlayer(file: file)
            player?.looping = true
//            player?.completionHandler = playbackCompletionHandler
        }
        variSpeed = AKVariSpeed(player)
        variSpeed?.rate = 1.0
        mainMixer = AKMixer(variSpeed, micBooster)
        AudioKit.output = mainMixer
        if !AudioKit.engine.isRunning {
            AudioKit.start()
        }
        currentFile = player?.audioFile
        completionHandler?(recorder?.audioFile)
    }
    
    deinit {
        if AudioKit.engine.isRunning {
            AudioKit.stop()
        }
    }
    
    func startRecording() throws {
        if AKSettings.headPhonesPlugged {
            micBooster?.gain = 1
        }
        do {
            try self.recorder?.record()
        } catch let error {
            print(error.localizedDescription)
        }
        currentNode = mic?.avAudioNode
    }
    
    func stopRecording(completion completionHandler: ((AKAudioFile) -> Void)?) {
        micBooster?.gain = 0
        do {
            try player?.reloadFile()
        } catch let err {
            print(err.localizedDescription)
        }
        let recordedDuration = player != nil ? player!.audioFile.duration  : 0
        if recordedDuration > 0.0 {
            recorder?.stop()
            
            let uuid = UUID().uuidString
            let temporaryFileName = "\(uuid).m4a"
            player?.audioFile.exportAsynchronously(name: temporaryFileName,
                                                   baseDir: .documents,
                                                   exportFormat: .m4a) { file, exportError in
                                                        if let error = exportError {
                                                            print(error.localizedDescription)
                                                        } else {
                                                            if let file = file {
                                                                print("Export succeeded \(file.url)")
                                                                completionHandler?(file)
                                                            }
                                                        }
            }
            currentNode = player?.avAudioNode
        }
    }
    
    func startPlaying() {
        player?.play()
    }
    
    func stopPlaying() {
        player?.stop()
    }
    
    func reset() {
        currentNode = mic?.avAudioNode
        player?.stop()
        do {
            try recorder?.reset()
        } catch let err {
            print(err.localizedDescription)
        }
    }
}
