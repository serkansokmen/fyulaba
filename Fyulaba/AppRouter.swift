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
        pushViewController(identifier: state.navigationState.rawValue, animated: shouldAnimate)
    }
}
