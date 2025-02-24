//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 02/02/25.
//
//  Main view for guide mode
//

import SwiftUI
import Combine
import Foundation
import Vision


struct GuideView: View {
    @StateObject var guideProcessor = GuideProcessor()
    @StateObject var frameHandler = FrameHandler()
    @State private var timer: AnyCancellable?
    
    var body: some View {
        VStack {
            if let image = guideProcessor.frame {
                
                GeometryReader { geometry in
                    ZStack {
                        
                        Image(uiImage: image)
                            .resizable()
                            .id(UUID())
                        
                        Canvas { context, size in
                            guard let joints = guideProcessor.joints, !joints.isEmpty else {
                                return
                            }
                            
                            for (joint1, joint2) in bodyConnections {
                                if let p1 = joints[joint1]?.location, let p2 = joints[joint2]?.location {
                                    let start = guideProcessor.normalizedToView(p1, in: size)
                                    let end = guideProcessor.normalizedToView(p2, in: size)
                                    
                                    context.stroke(
                                        Path { path in
                                            path.move(to: start)
                                            path.addLine(to: end)
                                        },
                                        with: .color(.blue), lineWidth: 3
                                    )
                                }
                            }
                            
                            for (joint, point) in joints {
                                let position = guideProcessor.normalizedToView(point.location, in: size)
                                context.fill(
                                    Path(ellipseIn: CGRect(x: position.x - 4, y: position.y - 4, width: 8, height: 8)),
                                    with: .color(.red)
                                )
                                
                                let viewDiagonal = hypot(size.width, size.height)
                                if joint == .rightShoulder || joint == .leftShoulder {
                                    
                                    let armDistanceInPixels = (guideProcessor.armDistance ?? 0.0) * viewDiagonal
                                    
                                    let radius = armDistanceInPixels
                                    
                                    context.stroke(
                                        Path(ellipseIn: CGRect(
                                            x: position.x - radius,
                                            y: position.y - radius,
                                            width: radius * 2,
                                            height: radius * 2
                                        )),
                                        with: .color(.green), lineWidth: 2
                                    )
                                }
                            }
                        }
                        
                        if let detections = guideProcessor.detections {
                            ForEach(detections) { detection in
                                let viewSize = geometry.size
                                
                                let centerInView = guideProcessor.normalizedToView(detection.center, in: viewSize)
                                let widthInView = detection.width * viewSize.width
                                let heightInView = detection.height * viewSize.height
                                Rectangle()
                                    .stroke(colorDictionary[detection.label] ?? .white, lineWidth: 2)
                                    .frame(width: widthInView, height: heightInView)
                                    .position(centerInView)
                            }
                        }
                        
                        if let personRect = guideProcessor.personRectangle {
                            let viewSize = geometry.size
                            
                            let centerInNormalizedSpace = CGPoint(
                                x: personRect.origin.x + personRect.width / 2,
                                y: personRect.origin.y + personRect.height / 2
                            )
                            
                            let normalizedCenter = NormalizedPoint(x: centerInNormalizedSpace.x, y: centerInNormalizedSpace.y)
                            let centerInView = guideProcessor.normalizedToView(normalizedCenter, in: viewSize)
                            let widthInView = personRect.width * viewSize.width
                            let heightInView = personRect.height * viewSize.height
                            
                            Rectangle()
                                .stroke(.white, lineWidth: 2)
                                .frame(width: widthInView, height: heightInView)
                                .position(centerInView)
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
        .ignoresSafeArea()
        .overlay {
            GuideOverlayView(guideProcessor: guideProcessor, frameHandler: frameHandler)
        }
        .onAppear {
            guideProcessor.setupChain(framePublisher: frameHandler.framePublisher)
            frameHandler.startSession()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
        
        
    }
    
    func startTimer() {
        timer = Timer.publish(every: 10.0, on: .main, in: .common) 
            .autoconnect()
            .sink { _ in
                if !guideProcessor.isProcessing && !frameHandler.isVideoPlaying {
                    Task {
                        await guideProcessor.process()
                    }
                } 
            }
    }
    
    func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
}

#Preview {
    GuideView()
}
