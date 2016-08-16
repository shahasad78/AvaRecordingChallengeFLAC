//
//  ViewController.swift
//  AvaChallengeRecordingApp
//
//  Created by Richard Martinez on 8/10/16.
//  Copyright © 2016 PhantomUniversalMediaProductions. All rights reserved.
//

import UIKit

class RecorderViewController: UIViewController {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!

    let audioManager = AudioManager()


    override func viewDidLoad() {
        super.viewDidLoad()
        audioManager.audioRecorderDelegate = self
        audioManager.audioPlayerDelegate = self
//        audioManager.audioSpeechSynthesizerDelegate = self
    }
    // ----------------------------------------+
    // MARK: - UI Setup
    // ----------------------------------------+
    func setRecordButtonOn(flag: Bool) {
        let image = flag ? UIImage(named: "record_recording")! : UIImage(named: "record_ready")!
        recordButton.setBackgroundImage(image, forState: UIControlState())
    }

    func setPlayButtonOn(flag: Bool) {
        let image = flag ? UIImage(named:"play_playing")! : UIImage(named: "play_ready")!
        playButton.setBackgroundImage(image, forState: UIControlState())
    }

    // =========================================

    // ----------------------------------------+
    // MARK: - IBActions
    // ----------------------------------------+

    @IBAction func onRecordPressed(sender: UIButton) {
        audioManager.record()
    }

    @IBAction func onPlayButtonPressed(sender: UIButton) {
        audioManager.playLast()
    }
    // =========================================


}

extension  RecorderViewController: AudioManagerRecorderDelegate {
    func didStartRecording() {
        setRecordButtonOn(true)
    }

    func didFinishRecording(url: NSURL?) {
        setRecordButtonOn(false)
    }

    func micAccessDenied(error: ErrorType?) {
        let theAlert = UIAlertController(title: "Requires Microphone Access",
                message: "Go to Settings > AvaChallengeRecordingApp > Allow AvaChallengeRecordingApp to Access Microphone.\nSet switch to enable.",
                preferredStyle: UIAlertControllerStyle.Alert)

        theAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.view?.window?.rootViewController?.presentViewController(theAlert, animated: true, completion:nil)
    }

}

extension  RecorderViewController: AudioManagerPlayerDelegate {
    func didStartPlaying() {
        setPlayButtonOn(true)
    }

    func didFinishPlaying() {
        setPlayButtonOn(false)
    }

}
