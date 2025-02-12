//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 09/02/25.
//

import SwiftUI

struct GuideOverlayView: View {
    @ObservedObject var guideProcessor: GuideProcessor
    @ObservedObject var frameHandler: FrameHandler
//    @ObservedObject var speech: Speech
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
                
                Text(guideProcessor.textForSpeech)
                
                Button {
                    Task {
                        await guideProcessor.process()

                    }
                } label: {
                    Text("GET Det")
                }
                //
//                Button {
//                    Task {
//                        await guideProcessor.getPose()
//                        //                    speech.say(text: guideProcessor.textForSpeech)
//                    }
//                } label: {
//                    Text("GET POSE")
//                }
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
