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

class MemoPlayerViewController: UIViewController, Routable {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.subscribe(self) { state in
            state.memoPlayer
        }
    }
    
    deinit {
        store.unsubscribe(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @IBAction func handlePlayTapped(_ sender: UIButton) {
        store.dispatch(StartPlaying())
    }
    
    @IBAction func handlePauseTapped(_ sender: UIButton) {
        store.dispatch(PausePlaying())
    }
    
    @IBAction func handleStopTapped(_ sender: UIButton) {
        store.dispatch(StopPlaying())
    }
}

extension MemoPlayerViewController: StoreSubscriber {
    
    func newState(state: MemoPlayerState) {
        
        guard let item = state.memo else { return }
        print(item)
        
        textView.text = item.text
        durationLabel.text = "Duration: \(item.file.duration)"
        
        tagListView.removeAllTags()
        item.features.forEach { tagListView.addTag($0.key) }
    }
}
