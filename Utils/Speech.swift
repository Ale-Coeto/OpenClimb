//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 02/02/25.
//

import Foundation
import Foundation
import AVFoundation

class Speech: ObservableObject {
    let synthesizer = AVSpeechSynthesizer()
    
    func say(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        
        
        // Configure the utterance.
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 1
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        // Retrieve the British English voice.
        let voice = AVSpeechSynthesisVoice(language: "en-US")
        
        
        // Assign the voice to the utterance.
        utterance.voice = voice
        


        // Tell the synthesizer to speak the utterance.
        synthesizer.speak(utterance)
    }
}
