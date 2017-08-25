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
    
    init() {
        self.recorder = nil
        self.mic = nil
        self.micBooster = nil
        self.micMixer = nil
        self.player = nil
        self.variSpeed = nil
        self.mainMixer = nil
    }
    
    func setup(with file: AKAudioFile?, completion completionHandler: @escaping (() -> Void)) {
        AKSettings.bufferLength = .medium
        do {
            try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
        } catch {
            AKLog("Could not set session category.")
        }
        AKSettings.defaultToSpeaker = true
        
        micMixer = AKMixer(mic)
        micBooster = AKBooster(micMixer)
        micBooster?.gain = 0
        
        if let file = file {
            recorder = try? AKNodeRecorder(node: micMixer, file: file)
        } else {
            recorder = try? AKNodeRecorder(node: micMixer)
        }
        
        if let file = recorder?.audioFile {
            player = try? AKAudioPlayer(file: file)
            player?.looping = true
//            player?.completionHandler = playbackCompletionHandler
            variSpeed = AKVariSpeed(player)
            variSpeed?.rate = 1.0
            mainMixer = AKMixer(variSpeed, micBooster)
            AudioKit.output = mainMixer
        }
    
        completionHandler()
    }
    
    func start() {
        guard recorder?.audioFile != nil else { return }
        AudioKit.start()
    }
    
    func stop() {
        guard recorder?.audioFile != nil else { return }
        AudioKit.stop()
    }
}
