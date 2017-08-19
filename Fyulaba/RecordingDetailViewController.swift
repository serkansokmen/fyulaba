//
//  RecordingDetailViewController.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 19/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import AudioKit


final class RecordingDetailViewController: UIViewController {

    @IBOutlet weak var plot: AKNodeOutputPlot!
    @IBOutlet weak var textView: UITextView!

    public var recording: Recording?
    var player: AKAudioPlayer!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let recording = self.recording else { return }
        guard let fileURL = recording.fileURL else { return }
        self.textView.text = recording.text
        self.setupPlayer(fileURL: fileURL)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.destroyPlayer()
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension RecordingDetailViewController: AudioPlaying {
    func setupPlayer(fileURL: URL) {
        guard let file = try? AKAudioFile(readFileName: fileURL.lastPathComponent, baseDir: .documents) else { return }
        self.player = try? AKAudioPlayer(file: file)
        self.player.looping = true
        self.plot.node = self.player

        AudioKit.output = player
        AudioKit.start()

        self.player.play()
    }
    func destroyPlayer() {
        self.player.stop()
        self.plot.node = nil
        AudioKit.stop()
    }
}
