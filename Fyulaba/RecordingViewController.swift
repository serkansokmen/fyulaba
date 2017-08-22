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
import ReSwift
import ReSwiftRouter


final class RecordingViewController: FormViewController, StoreSubscriber, Routable {

    static let identifier = "RecordingViewController"

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
        case speedRow = "speedRow"
        case deleteRecordingRow = "deleteRecordingRow"
    }

    private struct Constants {
        static let empty = ""
    }

    var delegate: SpeechRecordingDelegate?
    var recording: Recording?

    private var infoRow: LabelRow?
    private var recordRow: ButtonRow?
    private var resetRow: ButtonRow?
    private var resultRow: TextAreaRow?

    private var micMixer: AKMixer!
    private var recorder: AKNodeRecorder!
    private var player: AKAudioPlayer!
    private var micBooster: AKBooster!
    private var mainMixer: AKMixer!
    private var variSpeed: AKVariSpeed!
    private let mic = AKMicrophone()

    private var state: RecordingState?

    private var transcribeResultHandler: SpeechTranscribeResultHandler?
    private var transcribeErrorHandler: SpeechTranscribeErrorHandler?

    @IBAction func handleSave(_ sender: UIBarButtonItem) {
        guard let recording = self.recording else { return }
        self.delegate?.saveRecording(recording, completionHandler: {
            AudioKit.stop()
            self.dismiss(animated: true, completion: nil)
        })
    }

    @IBAction func handleCancel(_ sender: UIBarButtonItem) {
        AudioKit.stop()
        AKAudioFile.cleanTempDirectory()
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        requestSpeechAuthorization()

        isHeroEnabled = true
        view.heroID = HeroConstants.recordings.rawValue
        view.heroModifiers = [.scale(0.5), .fade]

        transcribeResultHandler = { result, sentiment in
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
        transcribeErrorHandler = { error in
            if let error = error {
                print("Transcription Error: \(error.localizedDescription)")
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        store.subscribe(self)
//        store.dispatch(LoadRecordingAction())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    func newState(state: AppState) {
//        self.recordings = state.recordings ?? []
    }
}

// MARK: - AudioKit
extension RecordingViewController {

    func setupAudio() {

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

        if let recording = self.recording {
            if let fileURL = recording.fileURL,
                Disk.exists(fileURL.lastPathComponent, in: .documents) {
                do {
                    let workingFile = try AKAudioFile(readFileName: fileURL.lastPathComponent, baseDir: .documents)
                    do {
                        self.recorder = try AKNodeRecorder(node: self.micMixer, file: workingFile)
                    } catch let error {
                        self.recorder = try AKNodeRecorder(node: self.micMixer)
                        self.showAlert(error.localizedDescription, type: .error)
                    }
                } catch let error {
                    self.recorder = try? AKNodeRecorder(node: self.micMixer)
                    self.showAlert(error.localizedDescription, type: .error)
                }
            } else {
                self.recorder = try? AKNodeRecorder(node: self.micMixer)
            }
        } else {
            self.recorder = try? AKNodeRecorder(node: self.micMixer)
        }

        if let file = recorder.audioFile {
            player = try? AKAudioPlayer(file: file)
            player.looping = true
            player.completionHandler = playingEnded
        }

        variSpeed = AKVariSpeed(player)
        variSpeed.rate = 1.0

        mainMixer = AKMixer(variSpeed, micBooster)

        AudioKit.output = mainMixer
    }

    func playingEnded() {
        DispatchQueue.main.async {
            self.setupUIForPlaying ()
        }
    }

    func setupUIForRecording () {
        state = .readyToRecord
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
    }

    func setupUIForPlaying () {
        state = .readyToPlay
        let recordedDuration = self.player != nil ? self.player.audioFile.duration  : 0
        infoRow?.title = "Recorded: \(String(format: "%0.1f", recordedDuration)) seconds"
        recordRow?.title = "Transcribe"
        resetRow?.disabled = false
        resetRow?.hidden = false
        form.allRows.forEach {
            $0.updateCell()
            $0.reload()
        }
    }

    func setupForm() {

        form +++  Section({ (section) in
            section.tag = FormTag.mainSection.rawValue
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
                            let temporaryFileName = "\(uuid).caf"
                            self.player.audioFile.exportAsynchronously(name: temporaryFileName,
                                                                       baseDir: .temp,
                                                                       exportFormat: .caf) { file, exportError in
                                                                        if let error = exportError {
                                                                            self.showAlert("Export Failed \(error)", type: .error)
                                                                        } else {
                                                                            if let file = file {
                                                                                self.recording = Recording(uuid: uuid,
                                                                                                           text: self.resultRow?.value ?? "",
                                                                                                           createdAt: Date(),
                                                                                                           fileURL: file.url)
                                                                                print("Export succeeded")
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

            <<< SliderRow(FormTag.speedRow.rawValue)
                .cellSetup { cell, row in
                    row.minimumValue = 0.01
                    row.maximumValue = 2.0
                    row.value = Float(self.variSpeed.rate)
                    row.disabled = Condition.function([FormTag.recordButtonRow.rawValue], { form in
                        return self.state == .recording
                    })
                    row.hidden = Condition.function([FormTag.recordButtonRow.rawValue], { form in
                        return self.state == .readyToRecord
                    })
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
                        self.delegate?.delete(recording)
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

//    private func makeHeaderView(for state: RecordingState?) -> HeaderFooterView<UIView>? {
//        var header = HeaderFooterView<UIView>(.callback({
//            guard let state = state else { return UIView(frame: .zero) }
//            switch state {
//            case .readyToRecord, .recording:
//                return AKNodeOutputPlot(self.mic, frame: CGRect(x: 0, y: 0, width: 100, height: 60))
//            case .readyToPlay, .playing:
//                return AKNodeOutputPlot(self.player, frame: CGRect(x: 0, y: 0, width: 100, height: 60))
//            }
//        }))
//        header.onSetupView = { view, section in
//            guard let view = view as? AKNodeOutputPlot else { return }
//            guard let state = state else { return }
//            switch state {
//            case .readyToRecord, .recording:
//                view.node = self.mic
//            case .readyToPlay, .playing:
//                view.node = self.player
//            }
//        }
//        header.height = { 132 }
//        return header
//    }

    private func makeFooterView() -> HeaderFooterView<UIView>? {
        var footer = HeaderFooterView<UIView>(.callback({
            let view = UIView(frame: .zero)
            return view
        }))
        footer.height = { 132 }
        return footer
    }

    private func updateHeaderView() {
        guard let state = self.state else { return }

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
            print(authStatus)

            /* The callback may not be called on the main thread. Add an operation to the main queue if you want to perform action on UI. */

            OperationQueue.main.addOperation {
                // here you can perform UI action, e.g. enable or disable a record button
                if !enabled {
                    self.showAlert(message!, type: .error)
                } else {

                    self.setupAudio()
                    AudioKit.start()

                    self.setupForm()
                    self.setupUIForRecording()
                }
            }
        }
    }
}
