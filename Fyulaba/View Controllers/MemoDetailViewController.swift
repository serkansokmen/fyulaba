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

class MemoDetailViewController: UIViewController, Routable {

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
//        print(state)
    }
}
