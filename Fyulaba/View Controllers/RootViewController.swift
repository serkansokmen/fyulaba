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

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks,
                                                                target: self,
                                                                action: #selector(self.handleBookmarksNavigation(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                                target: self,
                                                                action: #selector(self.createMemoTapped(_:)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    @objc func handleBookmarksNavigation(_ sender: UIBarButtonItem) {
        store.dispatch(RoutingAction(destination: .memoList))
    }

    @objc func createMemoTapped(_ sender: UIButton) {
        store.dispatch(RoutingAction(destination: .recorder))
    }

}

extension RootViewController: StoreSubscriber {
    
    func newState(state: AppState) {
        print(state)
    }
}

extension RootViewController: Routable, UIPopoverPresentationControllerDelegate {
//    func pushRouteSegment(routeElementIdentifier: String,
//                          completionHandler: @escaping RoutingCompletionHandler) -> Routable {
//
//        switch routeElementIdentifier {
//        case "MemoList":
//            let vc = MemoListViewController(nibName: MemoListViewController.identifier, bundle: nil)
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .popover
//            nav.preferredContentSize = CGSize(width: 200, height: 200)
//            let popover = nav.popoverPresentationController
//            popover?.delegate = self
//            popover?.permittedArrowDirections = .any
//            popover?.sourceView = self.view
//            popover?.sourceRect = CGRect(x: 100, y: 100, width: 100, height: 100)
//
//            present(vc, animated: true, completion: completionHandler)
//
//            return vc
//        default:
//            return RecorderViewController(nibName: RecorderViewController.identifier, bundle: nil)
//        }
//    }
//
//    func popRouteSegment(routeElementIdentifier: RouteElementIdentifier,
//                         completionHandler: @escaping RoutingCompletionHandler) {
//        if routeElementIdentifier == "MemoList" {
//            dismiss(animated: true, completion: completionHandler)
//        }
//    }

}
