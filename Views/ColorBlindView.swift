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
    
    var body: some View {
        VStack {
            if let image = colorFilterVM.frame {
                Image(uiImage: image)
                    .resizable()
                    .ignoresSafeArea()
//                    .scaledToFit()
            } else {
                Color(.black)
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
                            colorFilterVM.resetColor()
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
                            colorFilterVM.setColor()
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
            colorFilterVM.startSession()
        }
        .onDisappear {
            colorFilterVM.stopSession()
        }
       
        
        
    }
}

#Preview {
    ColorBlindView()
}
