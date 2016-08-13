//
// Created by Richard Martinez on 8/10/16.
// Copyright (c) 2016 PhantomUniversalMediaProductions. All rights reserved.
//

import Foundation

var appHasMicAccess = false


enum AudioStatus: Int {
    case stopped
    case playing
    case recording
    case speaking

    func audioName() -> String {
        let audioNames = [
                "Audio: Stopped",
                "Audio: Playing",
                "Audio: Recording"
        ]
        return audioNames[self.rawValue]
    }

    var description: String {
        return audioName()
    }
}

typealias URLGenerator = () -> NSURL
/// Returns a function that generates a temp Directory path
///  with an incremented integer appended to it
/// - Returns: a `URLGenerator` function object that returns a continuously incrementing fileName
func getFileURL(withExtension fileExtension: String) -> URLGenerator {
    var number = 0
    let searchPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let tempDir = searchPath[0] + "/tmp"
    return { () in
        let url = NSURL(fileURLWithPath: tempDir + "\(number)" + ".\(fileExtension)")
        number += 1
        return url
    }
}