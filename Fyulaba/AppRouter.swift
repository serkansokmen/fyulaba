//
//  AppRouter.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 24/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import ReSwift

enum RoutingDestination: String {
    case root = "RootViewController"
    case memoList = "MemoListViewController"
    case recorder = "RecorderViewController"
    case parent = "ParentViewController"
//    case player = "PlayerViewController"
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

        switch state.navigationState {
        case .root:
            navigationController.popToRootViewController(animated: shouldAnimate)
        case .memoList:
            pushViewController(identifier: MemoListViewController.identifier, animated: shouldAnimate)
//            let vc = instantiateViewController(identifier: MemoListViewController.identifier) as! MemoListViewController
//            let nav = UINavigationController(rootViewController: vc)
//            nav.modalPresentationStyle = .popover
//            nav.preferredContentSize = CGSize(width: 200, height: 200)
//            let popover = nav.popoverPresentationController
//            popover?.delegate = self
//            popover?.permittedArrowDirections = .any
//            popover?.sourceView = self.view
//            popover?.sourceRect = CGRect(x: 100, y: 100, width: 100, height: 100)
//
//            present(nav, animated: true, completion: completionHandler)
        case .recorder:
            pushViewController(identifier: RecorderViewController.identifier, animated: shouldAnimate)
        case .parent:
            navigationController.popViewController(animated: shouldAnimate)
        }

        guard state.navigationState != .parent else { return }
        pushViewController(identifier: state.navigationState.rawValue, animated: shouldAnimate)
    }
}
