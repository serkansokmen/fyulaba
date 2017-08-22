//
//  Store.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 21/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import ReSwift
import ReSwiftRouter
import ReSwiftRecorder
import RxSwift
import Disk

// App State
typealias RecordingElement = (route: [RouteElementIdentifier], routeSpecificData: Any?)

struct AppState: StateType, HasNavigationState {
    var navigationState: NavigationState
    var recordings: [Recording]?
}

// Actions

func loadRecordings(state: AppState, store: Store<AppState>) -> Action? {

    do {
        let retrievedRecordings = try Disk.retrieve("recordings.json",
                                                    from: .documents,
                                                    as: [Recording].self)
        DispatchQueue.main.async {
            store.dispatch(LoadRecordingsCompleteAction(recordings: retrievedRecordings))
        }
    } catch let error {
        DispatchQueue.main.async {
            store.dispatch(LoadRecordingsErrorAction(error: error))
        }
    }

    return nil
}

struct LoadRecordingsCompleteAction: Action {
    static let type = "RECORDINGS_ACTION_LOAD_RECORDINGS_COMPLETE"
    let recordings: [Recording]
}

struct LoadRecordingsErrorAction: Action {
    static let type = "RECORDINGS_ACTION_LOAD_RECORDINGS_ERROR"
    let error: Error?
}

// Reducers
struct AppReducer: Reducer {

    func handleAction(action: Action, state: AppState?) -> AppState {

        return AppState(
            navigationState: NavigationReducer.handleAction(action, state: state?.navigationState),
            recordings: recordingsReducer(state: state?.recordings ?? [], action: action)
        )
    }
}

func recordingsReducer(state: [Recording]?, action: Action) -> [Recording]? {
    switch action {
    case let action as LoadRecordingsCompleteAction:
        return action.recordings
//    case let action as LoadRecordingsErrorAction:
//        return action.recordings
//        break
    default:
        return nil
    }
}

class RecordingService {

//    static func isRepositoryBookmarked(state: AppState, currentRepository: Repository) -> Bool {
//
//        let bookmarkActive = !state.bookmarks.contains { route, data in
//            guard let repository = data as? Repository else { return false }
//
//            return RouteHash(route: route) == RouteHash(route: [mainViewRoute, repositoryDetailRoute])
//                && repository.name == currentRepository.name
//        }
//
//        return bookmarkActive
//    }

}

