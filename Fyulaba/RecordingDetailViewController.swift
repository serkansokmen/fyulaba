//
//  RecordingDetailViewController.swift
//  Fyulaba
//
//  Created by Serkan Sokmen on 19/08/2017.
//  Copyright © 2017 Serkan Sokmen. All rights reserved.
//

import UIKit
import AudioKit
import ChameleonFramework


final class RecordingDetailViewController: UIViewController {

    public var recording: Recording?

    @IBOutlet weak var plot: AKNodeOutputPlot!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var playButton: UIButton!

    @IBAction func playButtonTouched(_ sender: UIButton) {
        if (self.player.isPlaying) {
            self.player.pause()
        } else {
            self.player.play()
        }

        DispatchQueue.main.async {
            if (self.player.isPlaying) {
                self.playButton.setTitle("Pause", for: .normal)
            } else {
                self.playButton.setTitle("Play", for: .normal)
            }
        }
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        self.variSpeed.rate = Double(sender.value)
    }

    internal var player: AKAudioPlayer!
    private var variSpeed: AKVariSpeed!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let fileURL = self.recording?.fileURL else { return }
        self.setupPlayer(fileURL: fileURL)

//        self.tracker = AKFrequencyTracker.init(self.player, hopSize: 200, peakCount: 20)
//        self.silence = AKBooster(self.tracker, gain: 0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.destroyPlayer()
        super.viewWillDisappear(animated)
    }
}

extension RecordingDetailViewController: AudioPlaying {
    func setupPlayer(fileURL: URL) {

        guard let file = try? AKAudioFile(readFileName: fileURL.lastPathComponent, baseDir: .documents) else { return }

        self.player = try? AKAudioPlayer(file: file)
        self.player.looping = true

        self.textView.text = ""
        self.variSpeed = AKVariSpeed(self.player)
        self.variSpeed.rate = 1.0

        self.plot.node = self.player
        self.plot.plotType = .rolling
        self.plot.shouldFill = true
        self.plot.shouldMirror = true
        self.plot.color = .flatBlue

        AudioKit.output = self.variSpeed
        AudioKit.start()
    }
    func destroyPlayer() {
        self.player.stop()
        self.plot.node = nil
        AudioKit.stop()
    }
}
