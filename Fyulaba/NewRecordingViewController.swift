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
import ChameleonFramework
import Disk
import Eureka

final class NewRecordingViewController: FormViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private enum State {
        case readyToRecord
        case recording
        case readyToPlay
        case playing
    }

    private enum FormTag: String {
        case mainSection = "mainSection"
        case recordButtonRow = "recordButtonRow"
        case resetButtonRow = "resetButtonRow"
        case infoLabelRow = "infoLabelRow"
        case resultTextAreaRow = "resultTextAreaRow"
    }

    private struct Constants {
        static let empty = ""
    }

    var delegate: SpeechRecordingDelegate?

    private var infoRow: LabelRow?
    private var recordRow: ButtonRow?
    private var resetRow: ButtonRow?
    private var resultRow: TextAreaRow?

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
    private var newRecording: Recording?

    private var transcribeResultHandler: SpeechTranscribeResultHandler?
    private var transcribeErrorHandler: SpeechTranscribeErrorHandler?

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

    override func viewDidLoad() {
        super.viewDidLoad()

        requestSpeechAuthorization()
        setupAudio()
        setupForm()

        isHeroEnabled = true
        view.heroID = HeroConstants.recordings.rawValue
        view.heroModifiers = [.scale(0.5), .fade]

        self.transcribeResultHandler = { result, sentiment in
            guard let recording = self.newRecording else { return }
            self.newRecording = Recording(uuid: recording.uuid,
                                          text: result,
                                          createdAt: recording.createdAt,
                                          fileURL: recording.fileURL)
            if let sentiment = sentiment {
                self.resultRow?.value = "\(sentiment.emoji) \(result)"
            } else {
                self.resultRow?.value = result
            }
            self.resultRow?.reload()
        }
        self.transcribeErrorHandler = { error in
            print(error?.localizedDescription)
        }
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

// MARK: - AudioKit
extension NewRecordingViewController {

    func setupForm() {
        form +++ Section() { section in
            var header = HeaderFooterView<AKNodeOutputPlot>(.callback({
                let view = AKNodeOutputPlot(self.mainMixer, frame: CGRect(x: 0, y: 0, width: 100, height: 60))
                return view
            }))
            header.height = { 60 }
            section.tag = ""
            section.header = header
        }

        form.last!
            <<< ButtonRow(FormTag.recordButtonRow.rawValue).onCellSelection({ (cell, row) in
                switch self.state {
                case .readyToRecord :
                    DispatchQueue.main.async {
                        self.activityIndicator.startAnimating()
                        self.infoRow?.title = "Recording"
                        row.title = "Stop"
                        self.form.allRows.forEach {
                            $0.updateCell()
                            $0.reload()
                        }
                    }

                    self.state = .recording
                    // microphone will be monitored while recording
                    // only if headphones are plugged
                    if AKSettings.headPhonesPlugged {
                        self.micBooster.gain = 1
                    }
                    SpeechTranscriber.shared.recognizeSpeechFromNode(self.mic.avAudioNode,
                                                                     resultHandler: self.transcribeResultHandler!,
                                                                     errorHandler: self.transcribeErrorHandler!)
                    do {
                        try self.recorder.record()
                    } catch { self.showAlert("Errored recording.", type: .success) }

                case .recording :
                    // Microphone monitoring is muted
                    self.micBooster.gain = 0
                    do {
                        try self.player.reloadFile()
                    } catch { self.showAlert("Errored reloading.", type: .error) }

                    let recordedDuration = self.player != nil ? self.player.audioFile.duration  : 0
                    if recordedDuration > 0.0 {
                        self.recorder.stop()
                        let uuid = UUID().uuidString
                        self.player.audioFile.exportAsynchronously(name: "\(uuid).m4a",
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
                                        self.showAlert("Export succeeded", type: .success)
                                    } else {
                                        self.showAlert("Export Failed", type: .error)
                                    }
                                }
                        }
                        self.setupUIForPlaying ()

                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                        }
                    } else {
                        SpeechTranscriber.shared.recognizeSpeechFromNode(self.player.avAudioNode,
                                                                         resultHandler: self.transcribeResultHandler!,
                                                                         errorHandler: self.transcribeErrorHandler!)
                    }

                case .readyToPlay :
                    self.player.play()
                    self.state = .playing
                    self.infoRow?.title = "Playing"
                    self.recordRow?.title = "Stop"
                    self.form.allRows.forEach {
                        $0.updateCell()
                        $0.reload()
                    }

                case .playing :
                    self.player.stop()
                    self.setupUIForPlaying()
                }
            })
            <<< ButtonRow(FormTag.resetButtonRow.rawValue).onCellSelection({ (cell, row) in
                self.player.stop()
                do {
                    try self.recorder.reset()
                    guard let fileURL = self.newRecording?.fileURL else { return }
                    try Disk.remove(fileURL.lastPathComponent, from: .documents)
                } catch { print("Already reset") }

                self.setupUIForRecording()
            })
            <<< LabelRow(FormTag.infoLabelRow.rawValue)
            <<< TextAreaRow(FormTag.resultTextAreaRow.rawValue)

        infoRow = form.rowBy(tag: FormTag.infoLabelRow.rawValue)
        infoRow?.title = "Recording"

        recordRow = form.rowBy(tag: FormTag.recordButtonRow.rawValue)
        recordRow?.title = "Stop"

        resetRow = form.rowBy(tag: FormTag.resetButtonRow.rawValue)
        resetRow?.title = "Reset"
        resetRow?.disabled = true

        resultRow = form.rowBy(tag: FormTag.resultTextAreaRow.rawValue)

        form.allRows.forEach {
            $0.updateCell()
        }
    }

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

//    func transcribeAudio(_ node: AKNode) {
//
//        self.recognitionRequest?.endAudio()
//
//        // 1
//        if let recognitionTask = self.recognitionTask {
//            recognitionTask.cancel()
//            self.recognitionTask = nil
//        }
//
//        // 2
//        let inputNode = node.avAudioNode
//
//        // 3
//        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//        guard let recognitionRequest = self.recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
//        self.recognitionRequest?.shouldReportPartialResults = true
//
//        // 4
//        self.recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
//
//            var isFinal = false
//
//            // 5
//            if let result = result {
//                isFinal = result.isFinal
//                guard let recording = self.newRecording else { return }
//                let resultString = result.bestTranscription.formattedString
//                self.newRecording = Recording(uuid: recording.uuid,
//                                              text: resultString,
//                                              createdAt: recording.createdAt,
//                                              fileURL: recording.fileURL)
//                let sentiment = ClassificationService.shared.predictSentiment(from: recording.text)
//                self.resultRow?.value = "\(sentiment.emoji) \(self.newRecording!.text)"
//                self.resultRow?.reload()
//            }
//
//            // 6
//            if error != nil || isFinal {
//                inputNode.removeTap(onBus: 0)
//
//                self.recognitionRequest = nil
//                self.recognitionTask = nil
//            }
//        }
//
//        // 7
//        let recordingFormat = inputNode.outputFormat(forBus: 0)
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
//            self.recognitionRequest?.append(buffer)
//        }
//    }

    func playingEnded() {
        DispatchQueue.main.async {
            self.setupUIForPlaying ()
        }
    }

    func setupUIForRecording () {
        micBooster.gain = 0
        infoRow?.title = "Ready to record"
        recordRow?.title = "Record"
        recordRow?.disabled = false
        recordRow?.hidden = false
        resetRow?.disabled = true
        resetRow?.hidden = true
        form.allRows.forEach {
            $0.updateCell()
            $0.reload()
        }
        state = .readyToRecord
    }

    func setupUIForPlaying () {
        let recordedDuration = self.player != nil ? self.player.audioFile.duration  : 0
        infoRow?.title = "Recorded: \(String(format: "%0.1f", recordedDuration)) seconds"
        recordRow?.title = "Transcribe"
        resetRow?.disabled = false
        resetRow?.hidden = false
        form.allRows.forEach {
            $0.updateCell()
            $0.reload()
        }
        state = .readyToPlay
    }
}

// MARK: - Transcription management
extension NewRecordingViewController: SFSpeechRecognizerDelegate {

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        recordRow?.disabled = Condition(booleanLiteral: !available)
        recordRow?.updateCell()
        recordRow?.reload()
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
                    self.showAlert(message!, type: .error)
                } else {
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

