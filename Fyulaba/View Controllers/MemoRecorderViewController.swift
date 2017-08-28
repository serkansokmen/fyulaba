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
import TagListView

class MemoRecorderViewController: UIViewController, Routable {
    
    @IBOutlet weak var plotView: AKNodeOutputPlot!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopPlayingButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var transcribeButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var transcriptionTextView: UITextView!
    @IBOutlet weak var tagListView: TagListView!
    
    private var memoItem: MemoItem?
    
    private var gradientColor: UIColor!
    private var gradientStrokeColor: UIColor!
    private var gradientPlotColor: UIColor!
    private var gradientActiveColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gradientColor = GradientColor(.topToBottom, frame: plotView.bounds, colors: [.white, .flatWhite])
        gradientStrokeColor = GradientColor(.topToBottom, frame: plotView.bounds, colors: [.flatWhite, .white])
        gradientPlotColor = GradientColor(.topToBottom, frame: plotView.bounds, colors: [.flatSkyBlue, .flatPurple])
        
        plotView.color = gradientPlotColor
        plotView.shouldFill = true
        plotView.shouldMirror = true
        plotView.layer.borderWidth = 2.0
        plotView.layer.borderColor = gradientStrokeColor.cgColor
        plotView.layer.cornerRadius = 20.0
        plotView.layer.backgroundColor = gradientColor.cgColor
        plotView.backgroundColor = gradientColor
        
        tagListView.delegate = self
        tagListView.alignment = .left
        tagListView.enableRemoveButton = true
        tagListView.removeButtonIconSize = 8.0
        tagListView.removeIconLineWidth = 2.0
        
        transcriptionTextView.text = ""
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.handleBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.handleSave))
        navigationController?.hidesNavigationBarHairline = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { state in
            state.memoRecorder
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.dispatch(ResetMemoRecorder())
        store.dispatch(ResetTranscriptionResult())
        super.viewWillDisappear(animated)
    }
    
    @IBAction func handleSave(_ sender: UIBarButtonItem) {
        guard let item = self.memoItem else { return }
        persistMemoItemAndDismiss(item)
    }
    
    @IBAction func handleRecord(_ sender: UIButton) {
        store.dispatch(SetMemoRecorderStartRecording())
    }
    
    @IBAction func handleStopRecording(_ sender: UIButton) {
        stopRecording()
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
        store.dispatch(ResetTranscriptionResult())
    }

    @IBAction func handleTranscribeTapped(_ sender: UIButton) {
        guard let currentFile = MemoRecorder.shared.currentFile else { return }
        transcribeAudioFile(currentFile)
    }
}

extension MemoRecorderViewController: StoreSubscriber {
    func newState(state: MemoRecorderState) {
        
        memoItem = state.memo
        memoItem?.text = state.transcriptionResult
        memoItem?.sentiment = state.sentiment
        
        guard let fileURL = memoItem?.fileURL else { return }
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
            showAlert(error?.localizedDescription, type: .error)
            
        default:
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            playButton.isEnabled = false
            stopPlayingButton.isEnabled = false
            resetButton.isEnabled = false
            infoLabel.text = ""
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = state.transcriptionResult.count > 0 || !state.isTranscribing
        
        transcribeButton.isEnabled = !state.isTranscribing && state.memo.duration > 0.0
        transcriptionTextView.text = state.transcriptionResult
        infoLabel.text = state.sentiment?.emoji
        
        if state.isTranscribing {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        tagListView.removeAllTags()
        if state.features.count > 0 {
            tagListView.addTags(state.features.map { $0.key })
        }
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
            plotView.plotType = .buffer
        case .playing:
            plotView.plotType = .rolling
        default:
            break
        }
    }
}

extension MemoRecorderViewController: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void {
        print("Tag pressed: \(title), \(sender)")
    }
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void {
        print("Tag pressed: \(title), \(sender)")
        store.dispatch(RemoveFeatureTag(title: title))
    }
}
