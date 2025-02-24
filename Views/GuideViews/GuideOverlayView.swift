//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 09/02/25.
//
//  Overlay view for guide mode with annotations, titles and buttons
//

import SwiftUI

struct GuideOverlayView: View {
    @ObservedObject var guideProcessor: GuideProcessor
    @ObservedObject var frameHandler: FrameHandler
    @StateObject var vm = GuideVM()
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Guide Mode")
                        .foregroundStyle(.white)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button {
                        withAnimation {
                            vm.helpMode = true
                        }
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.white)
                            .font(.title2)
                    }
                }
                .padding()
                .background(Color("Primary"))
                
                Spacer()
                
                if frameHandler.isVideoPlaying {
                    Text("")
                } else {
                    Text(guideProcessor.textForSpeech)
                }
                Button {
                    frameHandler.mode = frameHandler.mode == .camera ? .video : .camera
                } label: {
                    Text(frameHandler.mode == .camera ? "Play Demo Video" : "Switch to Camera")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            if vm.helpMode {
                GuideHelpView(vm: vm)
                    .transition(.opacity.combined(with: .opacity))
            }
        }
    }
}

#Preview {
    GuideOverlayView(guideProcessor: GuideProcessor(), frameHandler: FrameHandler())
}
