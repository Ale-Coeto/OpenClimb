//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 06/02/25.
//
//  Overlay view with buttons, titles and annotations
//

import SwiftUI

struct ColorBlindOverlayView: View {
    @ObservedObject var vm: ColorBlindVM
    @ObservedObject var colorBlindProcessor: ColorBlindProcessor
    @ObservedObject var frameHandler: FrameHandler
    
    var body: some View {
        ZStack {
            VStack {
                
                // Header
                HStack {
                    Text("Color Blind Mode")
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
                
                
                if vm.isSetting {
                    DetectedColorView(color: colorBlindProcessor.centerColor)
                    Spacer()
                    
                } else {
                    VStack {
                        DetectedColorView(color: colorBlindProcessor.filterColor)
                        
                        Button {
                            vm.handleReset()
                            colorBlindProcessor.resetColor()
                            frameHandler.startSession()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.trianglehead.counterclockwise")
                                Text("Reset")
                            }
                            .padding()
                            .background(Color("Secondary"))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                        
                        Spacer()
                    }
                    .padding(.top)
                    
                }
                
                Spacer()
                
                // Capture Button
                VStack {
                    Text(vm.captureLabel)
                        .padding(.bottom)
                        .foregroundStyle(.white)
                    Button {
                        if !vm.isSetting {
                            frameHandler.toggleSession()
                        } else {
                            colorBlindProcessor.setColor()
                        }
                        vm.handleCapture()
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
            .blur(radius: vm.helpMode ? 10 : 0)
            if vm.helpMode {
                ColorBlindHelpView(vm: vm)
                    .transition(.opacity.combined(with: .opacity))
            }
        }
    }
}

#Preview {
    ColorBlindOverlayView(vm: ColorBlindVM(), colorBlindProcessor: ColorBlindProcessor(), frameHandler: FrameHandler())
}
