//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 03/02/25.
//
//  Class view model for colorbling mode view
//

import Foundation

class ColorBlindVM: ObservableObject {
    @Published var isSetting: Bool
    @Published var captureLabel: String
    @Published var capturedColor: String
    @Published var helpMode: Bool
    @Published var arrowOffset: CGFloat
    @Published var helpPageIndex: Int
    
    init() {
        self.isSetting = true
        self.captureLabel = "Set starting hold"
        self.capturedColor = ""
        self.arrowOffset = 0
        self.helpPageIndex = 0
        self.helpMode = true
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
