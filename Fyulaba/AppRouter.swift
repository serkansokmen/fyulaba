//
//  AppRouter.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift

enum X: String {
    case zero = "zero value"
    case one = "some one"
    case two = "in two"
}

enum RoutingDestination: String {
    case root = "RootViewController"
    case memoList = "MemoListViewController"
    case memoRecorder = "MemoRecorderViewController"
    case memoDetail = "MemoDetailViewController"
}


final class AppRouter {
    let navigationController: UINavigationController

    init(window: UIWindow) {
        navigationController = UINavigationController()
        window.rootViewController = navigationController

        store.subscribe(self) { state in
            state.routingState
        }
    }

    fileprivate func pushViewController(identifier: String, animated: Bool) {
        let viewController = instantiateViewController(identifier: identifier)
        let newViewControllerType = type(of: viewController)
        if let currentVc = navigationController.topViewController {
            let currentViewControllerType = type(of: currentVc)
            if currentViewControllerType == newViewControllerType {
                return
            }
        }
        navigationController.pushViewController(viewController, animated: animated)
    }

    private func instantiateViewController(identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
}


extension AppRouter: StoreSubscriber {
    func newState(state: RoutingState) {
        let shouldAnimate = navigationController.topViewController != nil
        
        switch state.destination {
        case .root:
            
            navigationController.dismiss(animated: true, completion: nil)
            pushViewController(identifier: state.destination.rawValue, animated: shouldAnimate)
            
        case .memoList:
            presentAsPopover(identifier: MemoListViewController.identifier, completion: nil)
        
        case .memoRecorder:
            presentAsPopover(identifier: MemoRecorderViewController.identifier, completion: nil)
        
        default:
            pushViewController(identifier: state.destination.rawValue, animated: shouldAnimate)
        }
    }
    
    func presentAsPopover(identifier: String, completion: (() -> Void)?) {
        let vc = instantiateViewController(identifier: identifier)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .popover
        nav.preferredContentSize = CGSize(width: 200, height: 200)
        let popover = nav.popoverPresentationController
        popover?.permittedArrowDirections = .any
        popover?.sourceView = navigationController.navigationItem.titleView
        popover?.sourceRect = CGRect(x: 100, y: 100, width: 100, height: 100)
        
        navigationController.present(nav, animated: true) {
            completion?()
        }
    }
}
