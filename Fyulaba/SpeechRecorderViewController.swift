//
//  SpeechRecorderViewController.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 18/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import Speech
import AVFoundation


class SpeechRecorderViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private var speechRecognizer = SFSpeechRecognizer()
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let audioEngine = AVAudioEngine()

    @IBAction func handleSave(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func handleCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func recordTapped(_ sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            self.activityIndicator.stopAnimating()
        } else {
            try? startRecording()
        }

        DispatchQueue.main.async {
            if self.audioEngine.isRunning {
                self.recordButton.setTitle("Stop", for: .normal)
            } else {
                self.recordButton.setTitle("Record", for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        resultTextView.text = ""

        speechRecognizer?.delegate = self

        self.requestSpeechAuthorization()
    }
}

// MARK: - Transcription management
extension SpeechRecorderViewController: SFSpeechRecognizerDelegate {

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        self.recordButton.isEnabled = available
    }

    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var enabled: Bool = false
            var message: String?

            switch authStatus {

            case .authorized:
                enabled = true

            case .denied:
                enabled = false
                message = "User denied access to speech recognition"

            case .restricted:
                enabled = false
                message = "Speech recognition restricted on this device"

            case .notDetermined:
                enabled = false
                message = "Speech recognition not yet authorized"
            }

            /* The callback may not be called on the main thread. Add an operation to the main queue if you want to perform action on UI. */

            OperationQueue.main.addOperation {
                // here you can perform UI action, e.g. enable or disable a record button
                if !enabled {
                    self.resultTextView.text = message
                } else {
                    self.resultTextView.text = ""
                }
            }
        }
    }

    func startRecording() throws {
        // 1
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }

        // 2
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode

        // 3
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        self.recognitionRequest?.shouldReportPartialResults = true

        // 4
        self.recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in

            var isFinal = false

            // 5
            if let result = result {
                self.resultTextView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }

            // 6
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }

        // 7
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()

        try audioEngine.start()
        self.activityIndicator.startAnimating()
    }
}



