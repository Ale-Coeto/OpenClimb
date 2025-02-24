//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 02/02/25.
//
//  Class to handle TTS (text-to-speech)
//

import Foundation
import Foundation
import AVFoundation

class Speech {
    let synthesizer = AVSpeechSynthesizer()
    
    func say(text: String) {
        let sentences = text.components(separatedBy: ". ")
        
        for sentence in sentences {
            let trimmedSentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedSentence.isEmpty { continue }
            
            let utterance = AVSpeechUtterance(string: trimmedSentence + ".")
            utterance.rate = 0.57
            utterance.pitchMultiplier = 0.8
            utterance.volume = 1
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.preUtteranceDelay = 0.6
            
            synthesizer.speak(utterance)
        }
    }
}
