//
//  SpeechRecordingDelegate.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 18/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import AudioKit

protocol SpeechRecording {
    func saveRecording(_ recording: Recording, completionHandler: (()->Void)?)
    func delete(_ recording: Recording)
}
