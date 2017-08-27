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
import Cartography
import ChameleonFramework

class MemoRecorderViewController: UIViewController, Routable {
    
    @IBOutlet weak var plotView: EZAudioPlot!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopPlayingButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuthorization(completion: {
            OperationQueue.main.addOperation {
                let file = try? AKAudioFile()
                setupWorkingAudioFile(file, completion: { workingFile in
                    store.dispatch(SetMemoRecorderReady(workingFile: workingFile))
                })
            }
        }, denied: { message in
            self.showAlert(message, type: .error)
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { state in
            state.memoRecorder
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    @IBAction func handleRecord(_ sender: UIButton) {
        store.dispatch(SetMemoRecorderStartRecording())
    }
    
    @IBAction func handleStopRecording(_ sender: UIButton) {
        store.dispatch(SetMemoRecorderStopRecording())
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
            durationLabel.isHidden = false
            
        case .recording:
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = true
            playButton.isEnabled = false
            stopPlayingButton.isEnabled = false
            resetButton.isEnabled = false
            durationLabel.isHidden = true
            
        case .playing:
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = false
            playButton.isEnabled = false
            stopPlayingButton.isEnabled = true
            resetButton.isEnabled = false
            durationLabel.isHidden = false
            
        case .paused:
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            playButton.isEnabled = true
            stopPlayingButton.isEnabled = false
            resetButton.isEnabled = true
            durationLabel.isHidden = true
            
        default:
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            playButton.isEnabled = false
            stopPlayingButton.isEnabled = false
            resetButton.isEnabled = false
            durationLabel.isHidden = true
        }
        
        durationLabel.text = "Duration: \(file.duration)"
        
//        self.updatePlotView(state)
    }
    
    private func updatePlotView(_ state: MemoRecorderState) {
        
        plotView.subviews.forEach { $0.removeFromSuperview() }
        
//        guard let audioNode = state.audioNode else { return }
        let plot = AKNodeOutputPlot(state.audioNode, frame: plotView.bounds)
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        
        switch state.recordingState {
        case .recording:
            plot.color = .flatRed
        case .playing:
            plot.color = .flatGreen
        default:
            plot.color = .flatGray
        }
        
        plotView.addSubview(plot)
        constrain(plot) {
            $0.edges == $0.superview!.edges
        }
    }
}
