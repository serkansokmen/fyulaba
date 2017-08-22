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

typealias SpeechTranscribeResultHandler = (String, SentimentType?) -> Void
typealias SpeechTranscribeErrorHandler = (Error?) -> Void

class SpeechTranscriber: NSObject, SFSpeechRecognizerDelegate {

    let speechRecognizer: SFSpeechRecognizer?

    static let shared: SpeechTranscriber = {
        let instance = SpeechTranscriber(with: Locale(identifier: Locale.preferredLanguages.first ?? "en"))

        // setup code
        return instance
    }()

    init(with locale: Locale) {
        self.speechRecognizer = SFSpeechRecognizer(locale: locale)
        super.init()
        
        self.speechRecognizer?.delegate = self
    }

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

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
                resultHandler(resultString, sentiment)
            }

            // 6
            if error != nil || isFinal {
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                errorHandler(error)
            }
        })

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
    }
}
