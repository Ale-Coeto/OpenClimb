//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 02/02/25.
//

import SwiftUI

struct GuideView: View {
    @StateObject var guideProcessor = GuideProcessor()
    @StateObject var frameHandler = FrameHandler()
    @StateObject var speech = Speech()
    var body: some View {
        VStack {
            Text(guideProcessor.textForSpeech)
            if let image = guideProcessor.frame {
                Image(uiImage: image)
                    .resizable()
                    .ignoresSafeArea()
            }
            
            Button {
                Task {
                    await guideProcessor.getPose()
                    speech.say(text: guideProcessor.textForSpeech)
                }
            } label: {
                Text("GET POSE")
            }
        }
        .onAppear {
            guideProcessor.setupChain(framePublisher: frameHandler.framePublisher)
            frameHandler.startSession()
        }
    }
        
}

#Preview {
    GuideView()
}
