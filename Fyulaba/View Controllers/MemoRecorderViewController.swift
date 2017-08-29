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
import SwiftDate

class MemoRecorderViewController: UIViewController, Routable {
    
    @IBOutlet weak var plotView: AKNodeOutputPlot!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopPlayingButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var localeButton: UIButton!
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
        
        requestAuthorization(completion: {
            OperationQueue.main.addOperation {
                store.dispatch(SetupAudio(memo: MemoItem()))
            }
        }, denied: { message in
            self.showAlert(message, type: .error)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recordButton.isEnabled = false
        store.subscribe(self) { state in
            state.memoRecorder
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        store.dispatch(ResetMemoRecorder())
        super.viewWillDisappear(animated)
    }
    
    @objc func handleSave(_ sender: UIBarButtonItem) {
        guard let item = self.memoItem else { return }
        persistMemoItemAndDismiss(item)
    }
    
    @IBAction func handleRecord(_ sender: UIButton) {
        store.dispatch(StartRecording())
    }
    
    @IBAction func handleStopRecording(_ sender: UIButton) {
        store.dispatch(PauseRecording())
    }
    
    @objc func handleBack(_ sender: UIBarButtonItem) {
        store.dispatch(RoutingAction(destination: .root))
    }
    
    @IBAction func handlePlay(_ sender: UIButton) {
        store.dispatch(StartPlaying())
    }
    
    @IBAction func handleStopPlaying(_ sender: UIButton) {
        store.dispatch(StopPlaying())
    }
    
    @IBAction func handleReset(_ sender: UIButton) {
        store.dispatch(ResetMemoRecorder())
    }

    @IBAction func handleTranscribeTapped(_ sender: UIButton) {
        guard let memo = memoItem else { return }
        transcribe(item: memo)
    }
}

extension MemoRecorderViewController: StoreSubscriber {
    func newState(state: MemoRecorderState) {
        
        memoItem = state.memo
        
        plotView.plotType = .buffer
        if let node = state.currentNode {
            plotView.node = node
        } else {
            plotView.node = nil
        }
        
        var fileDuration = 0.0
        try? state.player?.reloadFile()
        let duration = state.memo?.file.duration ?? 0.0
        fileDuration = duration
        
        switch state.recordingState {
        
        case .ready:
            let hasDuration = fileDuration > 0.0
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
            plotView.plotType = .rolling
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
            infoLabel.text = "Duration: \(fileDuration)"
        
        case let .error(error):
            showAlert(error?.localizedDescription, type: .error)
            
        default:
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = false
            playButton.isEnabled = false
            stopPlayingButton.isEnabled = false
            resetButton.isEnabled = false
            infoLabel.text = ""
        }
        
        transcribeButton.isEnabled = !state.isTranscribing && fileDuration > 0.0
        
        tagListView.removeAllTags()
        if let memo = state.memo {
            navigationItem.rightBarButtonItem?.isEnabled = memo.text.count > 0 && !state.isTranscribing
            if memo.features.count > 0 {
                tagListView.addTags(memo.features.map { $0.key })
            }
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        transcriptionTextView.text = memoItem?.text
        infoLabel.text = memoItem?.sentiment?.emoji
        
        if state.isTranscribing {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
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
