//
//  RecordingsReducer.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 22/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import ReSwift

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
