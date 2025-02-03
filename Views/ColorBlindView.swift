//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 29/01/25.
//

import SwiftUI

struct ColorBlindView: View {
    @StateObject var colorBlindVM = ColorBlindVM()
    @StateObject var colorFilterVM = FrameHandler()
    @StateObject private var frameProcessor = FrameProcessor()
    
    //    init() {
    //        // Initialize frameProcessor with the publisher from colorFilterVM
    //        frameProcessor.setup(framePublisher: colorFilterVM.framePublisher)
    ////        let frameProcessorInstance = FrameProcessor(framePublisher: colorFilterVM.framePublisher)
    ////        _frameProcessor = StateObject(wrappedValue: frameProcessorInstance)
    //    }
    //    @State private var frameProcessor: FrameProcessor? = nil
    
    var body: some View {
        
        VStack {
            
            if let image = frameProcessor.frame1 {
                
                Image(uiImage: image)
                    .resizable()
                    .ignoresSafeArea()
                    .id(UUID())
                //                    .scaledToFit()
            } else {
                ZStack {
                    Color(.black)
                    Text("Setting up")
                }
            }
        }
        .ignoresSafeArea()
        .overlay() {
            VStack {
                // Header
                HStack {
                    Text("Color Blind Mode")
                        .foregroundStyle(.white)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.white)
                            .font(.title2)
                    }
                }
                .padding()
                .background(Color("Primary"))
                
                
                if colorBlindVM.isSetting {
                    Spacer()
                    Text("|")
                    Text("- -")
                    Text("|")
                } else {
                    VStack {
                        Text("Color: \(colorBlindVM.capturedColor)")
                        Button {
                            colorBlindVM.handleReset()
                            frameProcessor.resetColor()
                            colorFilterVM.startSession()
                        } label: {
                            Text("Reset")
                        }
                    }
                    .padding(.top)
                    
                }
                
                Spacer()
                
                // Capture Button
                VStack {
                    Text(colorBlindVM.captureLabel)
                        .padding(.bottom)
                        .foregroundStyle(.white)
                    Button {
                        if !colorBlindVM.isSetting {
                            colorFilterVM.toggleSession()
                        } else {
                            frameProcessor.setColor()
                        }
                        colorBlindVM.handleCapture()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.gray)
                                .opacity(0.2)
                                .frame(width: 60)
                            Circle()
                                .stroke(Color.gray, lineWidth: 3)
                                .frame(width: 60)
                                .opacity(0.6)
                        }
                    }
                    
                    
                }
            }
        }
        .onAppear {
            
            
            //            frameProcessor = FrameProcessor(framePublisher: colorFilterVM.framePublisher)
            
            frameProcessor.setup(framePublisher: colorFilterVM.framePublisher)
            colorFilterVM.startSession()
            //            if frameProcessor == nil {
            //                            frameProcessor = FrameProcessor(frameHandler: colorFilterVM)
            //                        }
        }
        .onDisappear {
            colorFilterVM.stopSession()
        }
        
        
        
    }
}

#Preview {
    ColorBlindView()
}
