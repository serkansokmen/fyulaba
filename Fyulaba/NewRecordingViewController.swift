//
//  NewRecordingViewController.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 18/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import AudioKit
import Whisper
import ChameleonFramework
import Disk

final class NewRecordingViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private var inputPlot: AKNodeOutputPlot!
    @IBOutlet weak var infoLabel: UILabel!

    private enum State {
        case readyToRecord
        case recording
        case readyToPlay
        case playing
    }

    var delegate: SpeechRecordingDelegate?

    struct Constants {
        static let empty = ""
    }

    private var micMixer: AKMixer!
    private var recorder: AKNodeRecorder!
    private var player: AKAudioPlayer!
    private var tape: AKAudioFile!
    private var micBooster: AKBooster!
    private var moogLadder: AKMoogLadder!
    private var delay: AKDelay!
    private var mainMixer: AKMixer!
    private let mic = AKMicrophone()

    private var state = State.readyToRecord

    private var speechRecognizer: SFSpeechRecognizer!
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let classificationService = ClassificationService()
    private var newRecording: Recording?

    @IBAction func handleSave(_ sender: UIBarButtonItem) {
        guard let recording = self.newRecording else { return }
        self.delegate?.didComplete(recording)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func handleCancel(_ sender: UIBarButtonItem) {
        if let recording = self.newRecording,
            let fileURL = recording.fileURL {
            do {
                try Disk.remove(fileURL.lastPathComponent, from: .documents)
                print("Removed \(fileURL.lastPathComponent)")
            } catch let err {
                print(err.localizedDescription)
            }
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func recordTapped(_ sender: UIButton) {
        switch state {
        case .readyToRecord :
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
                self.infoLabel.text = "Recording"
                self.recordButton.setTitle("Stop", for: .normal)
            }

            state = .recording
            // microphone will be monitored while recording
            // only if headphones are plugged
            if AKSettings.headPhonesPlugged {
                micBooster.gain = 1
            }
            do {
                try recorder.record()
            } catch { self.showAlert("Errored recording.", type: .success) }

        case .recording :
            // Microphone monitoring is muted
            micBooster.gain = 0
            do {
                try player.reloadFile()
            } catch { self.showAlert("Errored reloading.", type: .error) }

            let recordedDuration = player != nil ? player.audioFile.duration  : 0
            if recordedDuration > 0.0 {
                recorder.stop()
                let uuid = UUID().uuidString
                player.audioFile.exportAsynchronously(name: "\(uuid).m4a",
                                                      baseDir: .documents,
                                                      exportFormat: .m4a) { file, exportError in
                                                        if let error = exportError {
                                                            self.showAlert("Export Failed \(error)", type: .error)
                                                        } else {
                                                            if let file = file {
                                                                self.newRecording = Recording(uuid: file.fileName,
                                                                                              text: "",
                                                                                              createdAt: Date(),
                                                                                              fileURL: file.url)
                                                                self.transcribeAudio(self.mainMixer)
                                                                self.showAlert("Export succeeded", type: .success)
                                                            } else {
                                                                self.showAlert("Export Failed", type: .error)
                                                            }
                                                        }
                }
                setupUIForPlaying ()

                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
            }

        case .readyToPlay :
            player.play()
            infoLabel.text = "Playing..."
            recordButton.setTitle("Stop", for: .normal)
            state = .playing
        case .playing :
            player.stop()
            setupUIForPlaying()
        }
    }

    @IBAction func resetButtonTouched(sender: UIButton) {
        player.stop()
        do {
            try recorder.reset()
            guard let fileURL = self.newRecording?.fileURL else { return }
            try Disk.remove(fileURL.lastPathComponent, from: .documents)
        } catch { self.showAlert("Error resetting", type: .error) }

        setupUIForRecording()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        resultTextView.text = ""
        speechRecognizer?.delegate = self
        self.requestSpeechAuthorization()
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale.autoupdatingCurrent)
        self.setupAudio()

        resetButton.setTitle(Constants.empty, for: UIControlState.disabled)
        recordButton.setTitle(Constants.empty, for: UIControlState.disabled)

        self.isHeroEnabled = true
        self.view.heroID = HeroConstants.recordings.rawValue
        self.view.heroModifiers = [.scale(0.5), .fade]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AudioKit.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioKit.stop()
    }
}

extension UIViewController {

    enum AlertType {
        case error
        case warning
        case success

        var color: UIColor {
            switch self {
            case .error:
                return .flatRed
            case .warning:
                return .flatOrange
            case .success:
                return .flatGreen
            }
        }
    }

    func showAlert(_ message: String, type: AlertType) {
        let whisper = Message(title: message, backgroundColor: .flatRed)
        guard let nav = self.navigationController else {
            print(message)
            return
        }
        Whisper.show(whisper: whisper, to: nav, action: .show)
    }
}

// MARK: - AudioKit
extension NewRecordingViewController {
    func setupAudio() {
        // Clean tempFiles !
        AKAudioFile.cleanTempDirectory()

        // Session settings
        AKSettings.bufferLength = .medium

        do {
            try AKSettings.setSession(category: .playAndRecord, with: .allowBluetoothA2DP)
        } catch {
            AKLog("Could not set session category.")
        }

        AKSettings.defaultToSpeaker = true

        // Patching
        inputPlot.node = mic
        micMixer = AKMixer(mic)
        micBooster = AKBooster(micMixer)

        // Will set the level of microphone monitoring
        micBooster.gain = 0
        recorder = try? AKNodeRecorder(node: micMixer)
        if let file = recorder.audioFile {
            player = try? AKAudioPlayer(file: file)
        }
        player.looping = true
        player.completionHandler = playingEnded

        moogLadder = AKMoogLadder(player)

        mainMixer = AKMixer(moogLadder, micBooster)

        AudioKit.output = mainMixer
    }

    func transcribeAudio(_ node: AKNode) {

        self.recognitionRequest?.endAudio()

        // 1
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // 2
        let inputNode = node.avAudioNode

        // 3
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = self.recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        self.recognitionRequest?.shouldReportPartialResults = true

        // 4
        self.recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in

            var isFinal = false

            // 5
            if let result = result {
                isFinal = result.isFinal
                guard let recording = self.newRecording else { return }
                let resultString = result.bestTranscription.formattedString
                self.newRecording = Recording(uuid: recording.uuid,
                                              text: resultString,
                                              createdAt: recording.createdAt,
                                              fileURL: recording.fileURL)
                let sentiment = self.classificationService.predictSentiment(from: recording.text)
                self.resultTextView.text = "\(sentiment.emoji) \(self.newRecording!.text)"
            }

            // 6
            if error != nil || isFinal {
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
    }

    func playingEnded() {
        DispatchQueue.main.async {
            self.setupUIForPlaying ()
        }
    }

    func setupUIForRecording () {
        state = .readyToRecord
        micBooster.gain = 0
        DispatchQueue.main.async {
            self.infoLabel.text = "Ready to record"
            self.recordButton.setTitle("Record", for: .normal)
            self.resetButton.isEnabled = false
            self.resetButton.isHidden = true
        }
    }

    func setupUIForPlaying () {
        DispatchQueue.main.async {
            let recordedDuration = self.player != nil ? self.player.audioFile.duration  : 0
            self.infoLabel.text = "Recorded: \(String(format: "%0.1f", recordedDuration)) seconds"
            self.recordButton.setTitle("Transcribe", for: .normal)
            self.resetButton.isEnabled = true
            self.resetButton.isHidden = false
        }
        state = .readyToPlay
    }
}

// MARK: - Transcription management
extension NewRecordingViewController: SFSpeechRecognizerDelegate {

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
                    self.setupUIForRecording()
                }
            }
        }
    }
}

//extension NewRecordingViewController: RPPreviewViewControllerDelegate {
//
//    func startVideoRecording() {
//        let recorder = RPScreenRecorder.shared()
//
//        recorder.startRecording{ (error) in
//            if let unwrappedError = error {
//                print(unwrappedError.localizedDescription)
//            }
//        }
//        DispatchQueue.main.async {
//            self.saveVideoButton.title = "Stop"
//        }
//    }
//
//    func stopVideoRecording() {
//        let recorder = RPScreenRecorder.shared()
//
//        recorder.stopRecording { [unowned self] (preview, error) in
//            if let unwrappedPreview = preview {
//                unwrappedPreview.previewControllerDelegate = self
//                self.navigationController?.present(unwrappedPreview, animated: true)
//            }
//        }
//        DispatchQueue.main.async {
//            self.saveVideoButton.title = "Record Screen"
//        }
//    }
//
//    public func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
//        self.navigationController?.dismiss(animated: true)
//    }
//}

