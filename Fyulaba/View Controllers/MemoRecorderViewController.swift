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
import AudioKitUI
import TagListView
import SwiftDate

class MemoRecorderViewController: UIViewController, Routable {
    
//    @IBOutlet weak var plotView: AKNodeOutputPlot!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopPlayingButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var transcribeButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var transcriptionTextView: UITextView!
//    @IBOutlet weak var tagListView: TagListView!
    
    private var memoItem: MemoItem?
    
    private var gradientColor: UIColor!
    private var gradientStrokeColor: UIColor!
    private var gradientPlotColor: UIColor!
    private var gradientActiveColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        plotView.color = gradientPlotColor
//        plotView.shouldFill = true
//        plotView.shouldMirror = true
//        plotView.layer.borderWidth = 2.0
//        plotView.layer.borderColor = gradientStrokeColor.cgColor
//        plotView.layer.cornerRadius = 0.0
//        plotView.layer.backgroundColor = gradientColor.cgColor
//        plotView.backgroundColor = gradientColor
//        plotView.plotType = .rolling
        
//        tagListView.delegate = self
//        tagListView.alignment = .left
//        tagListView.enableRemoveButton = true
//        tagListView.removeButtonIconSize = 8.0
//        tagListView.removeIconLineWidth = 2.0
        
        transcriptionTextView.text = ""
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.handleBack))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.handleSave))
        
        store.dispatch(requestSpeechAuthorization())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subscription in
            subscription.select { state in state.memoRecorder }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.dispatch(ResetRecording())
        store.unsubscribe(self)
    }
    
    @objc func handleSave(_ sender: UIBarButtonItem) {
        store.dispatch(SaveAndDismissRecording())
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
        store.dispatch(SetRecorderPlaying())
    }
    
    @IBAction func handleStopPlaying(_ sender: UIButton) {
        store.dispatch(SetRecorderStopped())
    }
    
    @IBAction func handleReset(_ sender: UIButton) {
        store.dispatch(SetupAudioRecorder(memo: nil))
    }

    @IBAction func handleTranscribeTapped(_ sender: UIButton) {
        store.dispatch(TranscribeMemoItem())
    }
}

extension MemoRecorderViewController: StoreSubscriber {
    func newState(state: MemoRecorderState) {
        
        memoItem = state.memo
        
        var fileDuration = 0.0
        try? state.player?.reloadFile()
        let duration = state.memo?.file.duration ?? 0.0
        fileDuration = duration
        
        let hasDuration = fileDuration > 0.0
        recordButton.isEnabled = false
        
        switch state.recordingState {
        
        case .ready:
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            playButton.isEnabled = hasDuration
            stopPlayingButton.isEnabled = false
            resetButton.isEnabled = hasDuration
            infoLabel.text = "Ready"
//            plotView.node = state.player
//            plotView.clear()
            navigationController?.isNavigationBarHidden = false
            
        case .recording:
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = true
            playButton.isEnabled = false
            stopPlayingButton.isEnabled = false
            resetButton.isEnabled = false
            infoLabel.text = "Recording..."
//            plotView.node = state.mic
//            plotView.plotType = .buffer
            navigationController?.isNavigationBarHidden = true
            
        case .playing:
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = false
            playButton.isEnabled = false
            stopPlayingButton.isEnabled = true
            resetButton.isEnabled = false
            infoLabel.text = "Playing..."
//            plotView.node = state.player
//            plotView.redraw()
//            plotView.plotType = .rolling
            navigationController?.isNavigationBarHidden = false
            
        case .paused:
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            playButton.isEnabled = true
            stopPlayingButton.isEnabled = false
            resetButton.isEnabled = true
            infoLabel.text = "Duration: \(fileDuration)"
//            plotView.plotType = .rolling
//            plotView.node = state.player
            navigationController?.isNavigationBarHidden = false
        
        case let .error(error):
            showAlert(error?.localizedDescription, type: .error)
            
        default:
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = false
            playButton.isEnabled = false
            stopPlayingButton.isEnabled = false
            resetButton.isEnabled = false
            infoLabel.text = ""
//            plotView.node = nil
            navigationController?.isNavigationBarHidden = false
        }
        
        transcribeButton.isEnabled = !state.isTranscribing
//            && fileDuration > 0.0
        
//        tagListView.removeAllTags()
        if let memo = state.memo {
            navigationItem.rightBarButtonItem?.isEnabled = hasDuration && !state.isTranscribing
            if memo.features.count > 0 {
//                tagListView.addTags(memo.features.map { $0.key })
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

//extension MemoRecorderViewController: TagListViewDelegate {
//    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void {
//        print("Tag pressed: \(title), \(sender)")
//    }
//    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void {
//        print("Tag pressed: \(title), \(sender)")
//        store.dispatch(RemoveFeatureTag(title: title))
//    }
//}
