//
//  RecordingsActions.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 22/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import ReSwift
import Disk

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
