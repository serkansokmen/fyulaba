//
//  RecordingViewController.swift
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
import Cartography

final class RecordingViewController: FormViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private enum RecordingState {
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
        case cutoffFrequencyRow = "cutoffFrequencyRow"
        case resonanceRow = "resonanceRow"
        case speedRow = "speedRow"
        case deleteRecordingRow = "deleteRecordingRow"
    }

    private struct Constants {
        static let empty = ""
    }

    var delegate: SpeechRecordingDelegate?
    var recording: Recording?

    private var mainSection: Section?
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
    private var variSpeed: AKVariSpeed!
    private let mic = AKMicrophone()

    private var state: RecordingState?

    private var transcribeResultHandler: SpeechTranscribeResultHandler?
    private var transcribeErrorHandler: SpeechTranscribeErrorHandler?

    @IBAction func handleSave(_ sender: UIBarButtonItem) {
        guard let recording = self.recording else { return }
        self.delegate?.didComplete(recording)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func handleCancel(_ sender: UIBarButtonItem) {
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
            guard let recording = self.recording else { return }
            self.recording = Recording(uuid: recording.uuid,
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
extension RecordingViewController {

    func setupForm() {

        mainSection = Section()
        mainSection?.tag = FormTag.mainSection.rawValue

        form +++  Section({ (section) in
            section.header = self.makeAudioPlotView()
            section.footer = self.makeFooterView()
        })
        form.last!
            <<< ButtonRow(FormTag.recordButtonRow.rawValue)
                .onCellSelection { (cell, row) in

                    guard let state = self.state else { return }
                    switch state {

                    case .readyToRecord:
                        DispatchQueue.main.async {
                            self.activityIndicator.startAnimating()
                            self.infoRow?.title = "Recording"
                            row.title = "Stop"
                            self.form.allRows.forEach {
                                $0.updateCell()
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

                    case .recording:
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
                                            self.recording = Recording(uuid: file.fileName,
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

                    case .readyToPlay:
                        self.player.play()
                        self.state = .playing
                        self.infoRow?.title = "Playing"
                        self.recordRow?.title = "Stop"
                        self.form.allRows.forEach {
                            $0.updateCell()
                        }

                    case .playing:
                        self.player.stop()
                        self.setupUIForPlaying()

                    }
                }

            <<< LabelRow(FormTag.infoLabelRow.rawValue)

            <<< TextAreaRow(FormTag.resultTextAreaRow.rawValue)

            <<< SliderRow(FormTag.cutoffFrequencyRow.rawValue)
                .cellSetup { (cell, row) in
                    row.minimumValue = 0
                    row.maximumValue = 5_000
                    row.value = Float(self.moogLadder.cutoffFrequency)
                }
                .onChange { (row) in
                    guard let value = row.value else { return }
                    self.moogLadder.cutoffFrequency = Double(value)
                }

            <<< SliderRow(FormTag.resonanceRow.rawValue)
                .cellSetup { (cell, row) in
                    row.minimumValue = 0
                    row.maximumValue = 5_000
                    row.value = Float(self.moogLadder.resonance)
                }
                .onChange { (row) in
                    guard let value = row.value else { return }
                    self.moogLadder.resonance = Double(value)
            }

            <<< SliderRow(FormTag.speedRow.rawValue)
                .cellSetup { cell, row in
                    row.minimumValue = 0.01
                    row.maximumValue = 2.0
                    row.value = Float(self.variSpeed.rate)
                }
                .onChange { (row) in
                    guard let value = row.value else { return }
                    self.variSpeed.rate = Double(value)
                    row.displayValueFor = { value in
                        guard let value = value else { return "" }
                        return String.init(format: "%0.1f Hz", value)
                    }
                }

            <<< ButtonRow(FormTag.resetButtonRow.rawValue)
                .onCellSelection { (cell, row) in
                    self.player.stop()
                    do {
                        try self.recorder.reset()
                        guard let fileURL = self.recording?.fileURL else { return }
                        try Disk.remove(fileURL.lastPathComponent, from: .documents)
                    } catch { print("Already reset") }

                    self.setupUIForRecording()
            }

            <<< ButtonRow(FormTag.deleteRecordingRow.rawValue)
                .cellSetup { cell, row in
                    row.title = "Delete Recording"
                    cell.tintColor = .flatRed
                }
                .onCellSelection { (cell, row) in
                    let alert = UIAlertController(title: "Deleting", message: "Are you sure you want to remove this recording?", preferredStyle: .alert)
                    let yes = UIAlertAction(title: "OK", style: .destructive, handler: { action in
                        self.player.stop()
                        do {
                            try self.recorder.reset()
                        } catch { print("Already reset") }

                        guard let recording = self.recording else { return }
                        self.delegate?.didDelete(recording)
                        self.dismiss(animated: true, completion: nil)
                    })
                    let no = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alert.addAction(yes)
                    alert.addAction(no)
                    self.present(alert, animated: true, completion: nil)
                }

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

        variSpeed = AKVariSpeed(self.player)
        variSpeed.rate = 1.0

        moogLadder = AKMoogLadder(variSpeed)
        moogLadder.cutoffFrequency = 300 // Hz
        moogLadder.resonance = 0.6

        mainMixer = AKMixer(moogLadder, micBooster)

        AudioKit.output = mainMixer
    }

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
        updateHeaderView()
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
        updateHeaderView()
        form.allRows.forEach {
            $0.updateCell()
            $0.reload()
        }
        state = .readyToPlay
    }

    private func updateHeaderView() {
        guard let section = mainSection else { return }
        section.header = makeAudioPlotView()
        section.reload()
    }

    private func makeAudioPlotView() -> HeaderFooterView<UIView>? {
        var header = HeaderFooterView<UIView>(.callback({
            guard let state = self.state else {
                return UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 60))
            }
            switch state {
            case .readyToRecord, .recording:
                return AKNodeOutputPlot(self.mic, frame: CGRect(x: 0, y: 0, width: 100, height: 60))
            case .readyToPlay, .playing:
                return AKNodeOutputPlot(self.player, frame: CGRect(x: 0, y: 0, width: 100, height: 60))
            }
        }))
        header.height = { 60 }
        return header
    }

    private func makeFooterView() -> HeaderFooterView<UIView>? {
        var footer = HeaderFooterView<UIView>(.callback({
            let view = UIView(frame: .zero)
            return view
        }))
        footer.height = { 132 }
        return footer
    }
}

// MARK: - Transcription management
extension RecordingViewController: SFSpeechRecognizerDelegate {

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
                    if let recording = self.recording {
                        if recording.fileURL != nil {
                            self.setupUIForPlaying()
                        } else {
                            self.setupUIForRecording()
                        }
                    } else {
                        self.setupUIForRecording()
                    }
                }
            }
        }
    }
}

//extension RecordingViewController: RPPreviewViewControllerDelegate {
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

