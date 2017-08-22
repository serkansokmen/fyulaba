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

        let state = state ?? RecordingState(recordings: .success([]))

        do {
            switch action {

            case _ as FetchRecordingsAction:
                let retrievedRecordings = try self.getRecordings()
                return RecordingState(recordings: .success(retrievedRecordings))

            case let action as SaveRecordingAction:
                var retrievedRecordings = try self.getRecordings()
                if let existingIndex = retrievedRecordings.index(where: { $0.uuid == action.updatedRecording.uuid }) {
                    retrievedRecordings[existingIndex] = action.updatedRecording
                } else {
                    retrievedRecordings.append(action.updatedRecording)
                }
                return RecordingState(recordings: .success(retrievedRecordings))

            case let action as RemoveRecordingAction:
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

            default:
                return state
            }
        } catch let err {
            return RecordingState(recordings: .failure(err))
        }
    }

    private func getRecordings() throws -> [Recording] {
        return try Disk.retrieve("recordings.json",
                                 from: .documents,
                                 as: [Recording].self)
    }
}
