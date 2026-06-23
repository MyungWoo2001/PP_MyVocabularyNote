//
//  SpeechService.swift
//  PP_MyDictionary
//
//  Created by Nguyen Minh Vu on 10/9/25.
//

import Foundation
import AVFoundation

class SpeechService {
    private let synthesizer = AVSpeechSynthesizer()
    
    func speak(_ text: String, languageCode: String = "en-US") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: languageCode)
        utterance.rate = 0.45
        synthesizer.speak(utterance)
    }
}

