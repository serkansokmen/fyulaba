//
//  RecorderViewController.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import ReSwift
import ReSwiftRouter
import AudioKit
import ChameleonFramework

class MemoRecorderViewController: UIViewController, Routable {
    
    @IBOutlet weak var plotView: AKNodeOutputPlot!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopPlayingButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var transcribeToggleSwitch: UISwitch!
    @IBOutlet weak var transcriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        store.subscribe(self) { state in
            state.memoRecorder
        }
        transcriptionTextView.text = ""
        plotView.plotType = .buffer
        plotView.shouldFill = true
        plotView.shouldMirror = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.handleBack))
    }
    
    deinit {
        store.unsubscribe(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        store.dispatch(ResetMemoRecorder())
        super.viewWillDisappear(animated)
    }
    
    @IBAction func handleRecord(_ sender: UIButton) {
        store.dispatch(SetMemoRecorderStartRecording())
    }
    
    @IBAction func handleStopRecording(_ sender: UIButton) {
        stopRecording { file in
            DispatchQueue.main.async {
                store.dispatch(SetMemoRecorderCompletedRecording(workingFile: file))
            }
        }
    }
    
    @objc func handleBack(_ sender: UIBarButtonItem) {
        store.dispatch(RoutingAction(destination: .root))
    }
    
    @IBAction func handlePlay(_ sender: UIButton) {
        store.dispatch(SetMemoRecorderStartPlaying())
    }
    
    @IBAction func handleStopPlaying(_ sender: UIButton) {
        store.dispatch(SetMemoRecorderStopPlaying())
    }
    
    @IBAction func handleReset(_ sender: UIButton) {
        store.dispatch(ResetMemoRecorder())
    }
    
    @IBAction func handleToggleSwitch(_ sender: UISwitch) {
        store.dispatch(SetAutoTranscribeEnabled(isEnabled: sender.isOn))
    }
}

extension MemoRecorderViewController: StoreSubscriber {
    func newState(state: MemoRecorderState) {
        
        guard let fileURL = state.memo.fileURL else { return }
        guard let file = try? AKAudioFile(forReading: fileURL) else { return }
        
        switch state.recordingState {
        
        case .ready:
            let hasDuration = file.duration > 0.0
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            playButton.isEnabled = hasDuration
            stopPlayingButton.isEnabled = false
            resetButton.isEnabled = hasDuration
            infoLabel.text = "Ready"
            transcribeToggleSwitch.isEnabled = hasDuration
            
        case .recording:
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = true
            playButton.isEnabled = false
            stopPlayingButton.isEnabled = false
            resetButton.isEnabled = false
            infoLabel.text = "Recording..."
            
        case .playing:
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = false
            playButton.isEnabled = false
            stopPlayingButton.isEnabled = true
            resetButton.isEnabled = false
            infoLabel.text = "Playing..."
            
        case .paused:
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            playButton.isEnabled = true
            stopPlayingButton.isEnabled = false
            resetButton.isEnabled = true
            infoLabel.text = "Duration: \(file.duration)"
        
        case let .error(error):
            infoLabel.text = error?.localizedDescription
            infoLabel.isHidden = false
            infoLabel.text = "Error!"
            
        default:
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            playButton.isEnabled = false
            stopPlayingButton.isEnabled = false
            resetButton.isEnabled = false
            infoLabel.text = ""
        }
        
        transcriptionTextView.text = state.transcriptionResult
        updatePlotView(state)
    }
    
    private func updatePlotView(_ state: MemoRecorderState) {
        
        if state.audioNode != nil {
            plotView.node = state.audioNode
        } else {
            plotView.node = nil
        }
        
        switch state.recordingState {
        case .recording:
            plotView.color = .flatWatermelon
        case .playing, .paused:
            plotView.color = .flatLime
        default:
            plotView.color = .flatWhite
        }
    }
}
