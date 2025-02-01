//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 29/01/25.
//

import Foundation

class ColorBlindVM: ObservableObject {
    @Published var isSetting: Bool
    @Published var captureLabel: String
    @Published var filterIntensity:Float = 0.9
    @Published var capturedColor: String
    
    
    init() {
        self.isSetting = true
        self.captureLabel = "Set starting hold"
        self.capturedColor = ""
    }
    
    
    func handleCapture() {
        if isSetting {
            isSetting = false
            captureLabel = "Freeze"
        }
        else {
            captureLabel = captureLabel == "Freeze" ? "Unfreeze" : "Freeze"
        }
    }
    
    func handleReset() {
        isSetting = true
        captureLabel = "Set starting hold"
    }
    
    
    
}
