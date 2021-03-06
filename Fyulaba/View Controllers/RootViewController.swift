//
//  RootViewController.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import ReSwift
import ReSwiftRouter
import AudioKit

class RootViewController: UIViewController, Routable {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks,
                                                                target: self,
                                                                action: #selector(self.handleBookmarksNavigation(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                target: self,
                                                                action: #selector(self.createMemoTapped(_:)))
        store.subscribe(self)
    }
    
    deinit {
        store.unsubscribe(self)
    }

    @objc func handleBookmarksNavigation(_ sender: UIBarButtonItem) {
        store.dispatch(RoutingAction(destination: .memoList))
    }

    @objc func createMemoTapped(_ sender: UIButton) {
        store.dispatch(RoutingAction(destination: .memoRecorder))
    }

}

extension RootViewController: StoreSubscriber {
    
    func newState(state: AppState) {
        print(state)
    }
}

