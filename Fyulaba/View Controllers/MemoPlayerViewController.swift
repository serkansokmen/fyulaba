//
//  MemoDetailViewController.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import ReSwift
import ReSwiftRouter
import TagListView

class MemoPlayerViewController: UIViewController, Routable, StoreSubscriber {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    
    @IBOutlet weak var speedRateSlider: UISlider!
    @IBOutlet weak var speedPitchSlider: UISlider!
    @IBOutlet weak var speedOverlapSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.subscribe(self) { subscription in
            subscription.select { state in state.memoPlayer }
        }
    }
    
    func newState(state: MemoPlayerState) {
        
        guard let item = state.memo else { return }
        print(item)
        
        textView.text = item.text
        durationLabel.text = "Duration: \(item.file.duration)"
        
        tagListView.removeAllTags()
        item.features.forEach { tagListView.addTag($0.key) }
    }
    
    deinit {
        store.unsubscribe(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.dispatch(SelectMemoItem(item: nil))
    }
    
    @IBAction func handlePlayTapped(_ sender: UIButton) {
        store.dispatch(SetPlayerPlaying())
    }
    
    @IBAction func handlePauseTapped(_ sender: UIButton) {
        store.dispatch(SetPlayerPaused())
    }
    
    @IBAction func handleStopTapped(_ sender: UIButton) {
        store.dispatch(SetPlayerStopped())
    }
    
    @IBAction func handleSpeedRate(_ sender: UISlider) {
        store.dispatch(SetSpeedRate(value: Double(sender.value)))
    }
    
    @IBAction func handleSpeedPitch(_ sender: UISlider) {
        store.dispatch(SetSpeedPitch(value: Double(sender.value)))
    }
    
    @IBAction func handleSpeedOverlap(_ sender: UISlider) {
        store.dispatch(SetSpeedOverlap(value: Double(sender.value)))
    }
    
}
