//
// Created by Richard Martinez on 8/10/16.
// Copyright (c) 2016 PhantomUniversalMediaProductions. All rights reserved.
//

import Foundation


public struct AudioDelegateType : OptionSetType { //, CustomStringConvertible{
    private enum DelegateType : Int, CustomStringConvertible {
        case player=1, recorder=2, speechSynthesizer=4

        var description : String {
            var shift = 0
            while (rawValue >> shift != 1){ shift += 1 }
            return ["player","recorder","speechSynthesizer"][shift]
        }
    }

    public  let rawValue : Int
    public  init(rawValue:Int){ self.rawValue = rawValue}
    private init(_ delegateType:DelegateType){ self.rawValue = delegateType.rawValue }

    static let Player  = AudioDelegateType(DelegateType.player)
    static let Recorder  = AudioDelegateType(DelegateType.recorder)
    static let SpeechSynthesizer = AudioDelegateType(DelegateType.speechSynthesizer)
    static let PlayerRecorder : AudioDelegateType = [Player, Recorder]
    static let PlayerSpeechSynthesizer : AudioDelegateType = [Player,SpeechSynthesizer]
    static let RecorderSpeechSynthesizer : AudioDelegateType = [Recorder,SpeechSynthesizer]
}