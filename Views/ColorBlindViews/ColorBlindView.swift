//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 03/02/25.
//
//  Main colorblind mode view
//

import SwiftUI

struct ColorBlindView: View {
    @StateObject var vm = ColorBlindVM()
    @StateObject var frameHandler = FrameHandler()
    @StateObject private var colorBlindProcessor = ColorBlindProcessor()
    
    var body: some View {
        
        VStack {
            
            if let image = colorBlindProcessor.frame1 {
                GeometryReader { geometry in
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .ignoresSafeArea()
                            .id(UUID())
                        
                        if vm.isSetting, let rect = colorBlindProcessor.samplingRectangle {
                            let imageSize = CGSize(
                                width: image.cgImage?.width ?? 1,
                                height: image.cgImage?.height ?? 1
                            )
                            let scaleX = geometry.size.width / imageSize.width
                            let scaleY = geometry.size.height / imageSize.height
                            
                            let scaledRect = CGRect(
                                x: rect.origin.x * scaleX,
                                y: rect.origin.y * scaleY,
                                width: rect.width * scaleX,
                                height: rect.height * scaleY
                            )
                            
                            Rectangle()
                            
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: scaledRect.width, height: scaledRect.height)
                                .position(
                                    x: scaledRect.midX,
                                    y: scaledRect.midY
                                )
                                .ignoresSafeArea()
                        }
                    }
                }
            } else {
                ZStack {
                    Color(.black)
                    Text("Loading Image")
                        .foregroundStyle(.white)
                }
            }
        }
        .blur(radius: vm.helpMode ? 10 : 0)
        .ignoresSafeArea()
        .overlay() {
            ColorBlindOverlayView(vm: vm, colorBlindProcessor: colorBlindProcessor, frameHandler: frameHandler)
        }
        .onAppear {
            colorBlindProcessor.setup(framePublisher: frameHandler.framePublisher)
            frameHandler.startSession()
        }
        .onDisappear {
            frameHandler.stopSession()
        }
    }
}


#Preview {
    ColorBlindView()
}
