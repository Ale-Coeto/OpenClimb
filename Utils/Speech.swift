//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 02/02/25.
//

import Foundation
import Foundation
import AVFoundation

class Speech {
    let synthesizer = AVSpeechSynthesizer()
    
    func say(text: String) {
        let utterance = AVSpeechUtterance(string: text)

        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 1
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.voice = voice
        
        synthesizer.speak(utterance)
    }
}
