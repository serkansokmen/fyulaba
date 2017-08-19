//
//  AudioPlayerService.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 19/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import Foundation
import AudioKit


protocol AudioPlaying {
    var player: AKAudioPlayer! { get }
    func setupPlayer(fileURL: URL)
    func destroyPlayer()
}
