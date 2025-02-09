//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 06/02/25.
//

import SwiftUI

struct ColorBlindOverlayView: View {
    @ObservedObject var vm: ColorBlindVM
    @ObservedObject var frameProcessor: ColorBlindProcessor
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
                    HStack (alignment: .center) {
                        Text("Color: \(closestColorName(for: frameProcessor.centerColor))")
                            .foregroundStyle(.white)
                        Rectangle()
                            .fill(
                                Color(
                                    red: Double(frameProcessor.centerColor?.red ?? 0) / 255.0,
                                    green: Double(frameProcessor.centerColor?.green ?? 0) / 255.0,
                                    blue: Double(frameProcessor.centerColor?.blue ?? 0) / 255.0
                                )
                            )
                            .frame(width: 10, height: 10)
                    }
                    Spacer()
//                        Spacer()
//                        Text("|")
//                        Text("- -")
//                        Text("|")
                } else {
                    VStack {
                        HStack (alignment: .center) {
                            Text("Color: \(closestColorName(for: frameProcessor.filterColor!))")
                                .foregroundStyle(.white)
                            Rectangle()
                                .fill(
                                    Color(
                                        red: Double(frameProcessor.filterColor?.red ?? 0) / 255.0,
                                        green: Double(frameProcessor.filterColor?.green ?? 0) / 255.0,
                                        blue: Double(frameProcessor.filterColor?.blue ?? 0) / 255.0
                                    )
                                )
                                .frame(width: 10, height: 10)
                        }
                        Spacer()
                        Text("Color: \(vm.capturedColor)")
                        Button {
                            vm.handleReset()
                            frameProcessor.resetColor()
                            frameHandler.startSession()
                        } label: {
                            Text("Reset")
                        }
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
                            frameProcessor.setColor()
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
    ColorBlindOverlayView(vm: ColorBlindVM(), frameProcessor: ColorBlindProcessor(), frameHandler: FrameHandler())
}
