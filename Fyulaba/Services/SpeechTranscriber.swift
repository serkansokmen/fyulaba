//
//  SpeechTranscriber.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 21/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import Speech
import AudioKit

enum SpeechTranscriptionError: Error {
    case error(String)
}

typealias SpeechTranscribeResultHandler = (String, SentimentType?, [TranscriptionFeature]) -> Void
typealias SpeechTranscribeErrorHandler = (SpeechTranscriptionError?) -> Void

class SpeechTranscriber: NSObject, SFSpeechRecognizerDelegate {

    let speechRecognizer: SFSpeechRecognizer?
    
    static let shared: SpeechTranscriber = {
        let instance = SpeechTranscriber()
        // setup code
        return instance
    }()
    
    override init() {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale.autoupdatingCurrent)
        super.init()
        
        self.speechRecognizer?.delegate = self
    }
    
    private var locale: Locale = Locale.autoupdatingCurrent
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    func recognizeSpeechFromAudioFile(_ url: URL,
                                      result resultHandler: @escaping SpeechTranscribeResultHandler,
                                      error errorHandler: @escaping SpeechTranscribeErrorHandler) {
        let request = SFSpeechURLRecognitionRequest(url: url)
        speechRecognizer?.recognitionTask(with: request) { result, error in
            
            guard let result = result else {
                errorHandler(.error("There was an error transcribing that file"))
                return
            }
            
            if result.isFinal {
                let resultString = result.bestTranscription.formattedString
                let sentiment = ClassificationService.shared.predictSentiment(from: resultString)
                let features = ClassificationService.shared.features(from: resultString)
                resultHandler(resultString, sentiment, features)
            }
            
            if error != nil {
                errorHandler(.error(error!.localizedDescription))
            }
        }
    }

    func recognizeSpeechFromNode(_ inputNode: AVAudioNode?,
                                 resultHandler: @escaping SpeechTranscribeResultHandler,
                                 errorHandler: @escaping SpeechTranscribeErrorHandler) {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let inputNode = inputNode else {
            fatalError("Audio engine has no input node")
        }

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }

        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { result, error in

            var isFinal = false

            // 5
            if let result = result {
                isFinal = result.isFinal
                let resultString = result.bestTranscription.formattedString
                let sentiment = ClassificationService.shared.predictSentiment(from: resultString)
                let features = ClassificationService.shared.features(from: resultString)
                resultHandler(resultString, sentiment, features)
            }

            // 6
            if error != nil || isFinal {
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                errorHandler(.error(error!.localizedDescription))
            }
        })

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
    }
}
