//
// Created by Richard Martinez on 8/10/16.
// Copyright (c) 2016 PhantomUniversalMediaProductions. All rights reserved.
//

import Foundation

//
// Created by Richard Martinez on 8/8/16.
// Copyright (c) 2016 PhantomUniversalMediaProductions. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol AudioManagerRecorderDelegate {
    func didStartRecording()
    func didFinishRecording(url: NSURL?)
    func micAccessDenied(error: ErrorType?)
}

protocol AudioManagerSpeechSynthesizerDelegate {
    func didStartSpeaking(utterance: AVSpeechUtterance)
    func didFinishSpeaking(utterance: AVSpeechUtterance)
}
protocol AudioManagerPlayerDelegate {
    func didStartPlaying()
    func didFinishPlaying()
}


/// Handles All of the Necessary Setup for Text-to-Speech synthesis
/// Responds to all AVSpeechSynthesizerDelegate methods
class AudioManager: NSObject {

    // Delegates
    // =========
    var audioPlayerDelegate: AudioManagerPlayerDelegate?
    var audioRecorderDelegate: AudioManagerRecorderDelegate?
    var audioSpeechSynthesizerDelegate: AudioManagerSpeechSynthesizerDelegate?

    /// State Machine
    var audioStatus: AudioStatus = .stopped


    // MARK: - Audio Players, Recorders, SpeechSynthesizers
    private var audioPlayer: AVAudioPlayer!
    private var audioRecorder: AVAudioRecorder!
    private let synthesizer = AVSpeechSynthesizer()
    var speechTimer: CGFloat = 0.0

    // -------------------------------
    // AV Helper properties
    // -------------------------------
    private var textQueue = [String]()  // Stores a queue of text for the speech recognizer
    var updateTimer: CADisplayLink!     // Used to run updates every cycle
    let urlGen = getFileURL(withExtension: "wav")   // a URLGenerator function that generates a unique filePath
    var tempFiles = [NSURL]()   // Stores URLS for recorded files
    var recordFileURL: NSURL
    // ===============================


    // -------------------------------------------------+
    // MARK: - Initializers
    // -------------------------------------------------+
    override init() {
        self.recordFileURL = urlGen()
        super.init()
        setupRecorder()
    }
    // =================================================+

    // -------------------------------------------------+
    // MARK: - Accessors
    // -------------------------------------------------+
    func setDelegateTypes(delegateTypes: AudioDelegateType) {

    }

    func addToQueue(text: String) {
        if !text.isEmpty {
            textQueue.append(text)
        }
    }
    // =================================================+

    /// `timerUpdates:` executes a provided block in the current run loop in order to receive record and playback timer updates.
    /// - Parameter: onThread: the thread on which to execute the given block
    /// - Parameter: withBlock: a block that takes no params and returns void to be executed
    func timerUpdates(onThread thread: dispatch_queue_t, withBlock block: () -> ()) {

            // TODO: Execute this in the CADisplayLink update loop
            dispatch_async(thread, block)

    }

    func startSpeaking ()  {

    }

    // -------------------------------------------------+
    // MARK: - AVFoundation Setup Methods
    // -------------------------------------------------+
    private func setupRecorder()  {
        let recordSettings: [String: AnyObject] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 16000.0,
                AVNumberOfChannelsKey: 1,
                AVLinearPCMIsBigEndianKey: false,
                AVLinearPCMIsFloatKey: false,
                AVEncoderBitRateKey: 16,
                AVLinearPCMIsNonInterleaved: false,
                AVLinearPCMBitDepthKey: 16,
                AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(URL: recordFileURL, settings: recordSettings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {
            print("Error: attempt to create AVAudioRecorder failed miserably!")
        }
    }
    // =================================================+


    // -------------------------------------------------+
    // MARK: - AVFoundation Transport Methods
    // -------------------------------------------------+

    // Play Methods
    // ============
    func play(fileUrl url: NSURL) {
        if audioStatus == .stopped {
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: url)
                audioPlayer.delegate = self
                if audioPlayer.duration > 0.0 {
                    startUpdateLoop()
                    audioPlayer.play()
                    audioStatus = .playing
                    audioPlayerDelegate?.didStartPlaying()
                }
            } catch let error as NSError {
                print("Audio playback error: \(error.localizedDescription)")
            }
        } else if audioStatus == .playing {
            audioStatus = .stopped
            audioPlayer.stop()
            stopUpdateLoop()
            audioPlayerDelegate?.didFinishPlaying()
        }
    }

    func playAll ()  {
        // TOOO: Implement Play Queue
    }

    func playLast() {
        if let url = tempFiles.last {
            play(fileUrl: url)
        }
    }

    func stopPlayback() {
        stopUpdateLoop()
        audioStatus = .stopped
        audioRecorder.stop()
    }

    // Record Methods
    // ==============
    func record() {
        if appHasMicAccess == true {
            if audioStatus != .playing || audioStatus != .speaking {

                switch audioStatus {
                case .stopped:
                    startUpdateLoop()
                    audioStatus = .recording
                    audioRecorder.record()
                    audioRecorderDelegate?.didStartRecording()
                case .recording:
                    stopRecording()
                default:
                    break
                }
            }
        } else {
            audioRecorderDelegate?.micAccessDenied(nil)

        }

    }

    func stopRecording() {
        stopUpdateLoop()
        audioStatus = .stopped
        audioRecorder.stop()
    }
    // =================================================+

    // -------------------------------------------------+
    // MARK: - Update Methods and Callbacks
    // -------------------------------------------------+

    func startUpdateLoop() {
        // TODO: Implement CADisplayLink integration with NSRunLoop
    }

    func stopUpdateLoop() {
        // TODO: invalidate CADisplaylink
    }
    // =================================================+

}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {

        stopUpdateLoop()
        audioStatus = .stopped
        audioPlayerDelegate?.didFinishPlaying()
    }

    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
    }
}

extension AudioManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didStartSpeechUtterance utterance: AVSpeechUtterance) {
    }

    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        audioSpeechSynthesizerDelegate?.didFinishSpeaking(utterance)
    }

    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didPauseSpeechUtterance utterance: AVSpeechUtterance) {
    }

    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didContinueSpeechUtterance utterance: AVSpeechUtterance) {
    }

    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didCancelSpeechUtterance utterance: AVSpeechUtterance) {
    }

    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
    }

}

extension  AudioManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        audioRecorderDelegate?.didFinishRecording(recorder.url)
        tempFiles.append(recorder.url)

        // Set up files for flac conversion
        let flacOutFile = (recorder.url.URLByDeletingPathExtension!.absoluteString as NSString).UTF8String
        let flacInFile = (recorder.url.absoluteString as NSString).UTF8String
        let outFiles = flac_file_array()

        // Internal housekeeping for memory freeing later
//        outputFileBuffers.append((count: 1024, buffer: outFiles))

        let status = convertWavToFlac(flacInFile, flacOutFile, 0, outFiles)
        print("Convert status finished with code: \(status)")
        
        recordFileURL = urlGen()
        
    }

    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
    }
}