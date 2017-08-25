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

class MemoRecorderViewController: UIViewController, Routable {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { state in
            state.memoItems
        }
        store.dispatch(FetchMemoListingAction())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

}

extension MemoRecorderViewController: StoreSubscriber {
    func newState(state: MemoItemsState) {
        print(state)
    }
}
