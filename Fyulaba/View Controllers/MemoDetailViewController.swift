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

class MemoDetailViewController: UIViewController, Routable {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.subscribe(self) { state in
            state.memoItems
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
}

extension MemoDetailViewController: StoreSubscriber {
    
    func newState(state: MemoItemsState) {
        
        guard let item = state.selectedItem else { return }
        print(item)
        
        textView.text = item.text
        durationLabel.text = "Duration: \(item.file.duration)"
        
        tagListView.removeAllTags()
        item.features.forEach { tagListView.addTag($0.key) }
    }
}
