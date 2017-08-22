//
//  RecordingsReducer.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 22/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import ReSwift
import Disk


struct RecordingReducer: Reducer {

    func handleAction(action: Action, state: RecordingState?) -> RecordingState {

        switch action {
        case _ as ReSwiftInit:
            break
        case _ as FetchRecordingsAction:
            do {
                let retrievedRecordings = try self.getRecordings()
                return RecordingState(recordings: .success(retrievedRecordings))
            } catch let err {
                return RecordingState(recordings: .failure(err))
            }

        case let action as SaveRecordingAction:
            do {
                var retrievedRecordings = try self.getRecordings()
                if let existingIndex = retrievedRecordings.index(where: { $0.uuid == action.updatedRecording.uuid }) {
                    retrievedRecordings[existingIndex] = action.updatedRecording
                } else {
                    retrievedRecordings.append(action.updatedRecording)
                }
                return RecordingState(recordings: .success(retrievedRecordings))
            } catch let err {
                return RecordingState(recordings: .failure(err))
            }

        case let action as RemoveRecordingAction:
            do {
                var retrievedRecordings = try self.getRecordings()
                if let existingIndex = retrievedRecordings.index(where: { $0.uuid == action.recording.uuid }) {
                    let existingRecording = retrievedRecordings[existingIndex]
                    retrievedRecordings.remove(at: existingIndex)
                    try Disk.save(retrievedRecordings, to: .documents, as: "recordings.json")
                    if let fileURL = existingRecording.fileURL {
                        try Disk.remove(fileURL.lastPathComponent, from: .documents)
                    }
                }
                return RecordingState(recordings: .success(retrievedRecordings))
            } catch let err {
                return RecordingState(recordings: .failure(err))
            }

        default:
            break
        }

        return state ?? RecordingState(recordings: .success([]))
    }

    private func getRecordings() throws -> [Recording] {
        return try Disk.retrieve("recordings.json",
                                 from: .documents,
                                 as: [Recording].self)
    }
}
