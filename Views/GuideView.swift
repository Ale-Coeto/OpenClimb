//
//  SwiftUIView.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 02/02/25.
//

import SwiftUI
import Combine

struct GuideView: View {
    @StateObject var guideProcessor = GuideProcessor()
    @StateObject var frameHandler = FrameHandler()
    @StateObject var speech = Speech()
    @State private var timer: AnyCancellable?
    
    var body: some View {
        VStack {
//            Text(guideProcessor.textForSpeech)
            if let image = guideProcessor.frame {
                
                GeometryReader { geometry in
                    ZStack {
                        
                        Image(uiImage: image)
                            .resizable()
//                            .ignoresSafeArea()
                            .id(UUID())
                       
                        Canvas { context, size in
                            // Check if there are joints before drawing
                            guard let joints = guideProcessor.joints, !joints.isEmpty else {
                                return // Skip drawing if no joints detected
                            }

                            // Draw connections
                            for (joint1, joint2) in guideProcessor.bodyConnections {
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

                            // Draw joint circles
                            for (_, point) in joints {
                                let position = guideProcessor.normalizedToView(point.location, in: size)
                                context.fill(
                                    Path(ellipseIn: CGRect(x: position.x - 4, y: position.y - 4, width: 8, height: 8)),
                                    with: .color(.red)
                                )
                            }
                        }
                        
                        if let detections = guideProcessor.detections {
//                            let imageSize = CGSize(
//                                width: image.cgImage?.width ?? 1,
//                                height: image.cgImage?.height ?? 1
//                            )

                            ForEach(detections) { detection in
                                let viewSize = geometry.size // SwiftUI view size

                                let centerInView = guideProcessor.normalizedToView(detection.center, in: viewSize)
                                let widthInView = detection.width * viewSize.width
                                let heightInView = detection.height * viewSize.height
                                Rectangle()
                                    .stroke(colorDictionary[detection.label] ?? .white, lineWidth: 2)
                                    .frame(width: widthInView, height: heightInView)
                                    .position(centerInView)
                            }
                        }
                        
                    }
                }
            }
            
            Button {
                Task {
                    await guideProcessor.getDetections()
                    speech.say(text: guideProcessor.textForSpeech)
                }
            } label: {
                Text("GET Det")
            }
//            
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
//            startTimer()
            
        }
        .onDisappear {
            stopTimer()
        }
        
        
    }
    
    func startTimer() {
            timer = Timer.publish(every: 10.0, on: .main, in: .common) // Change 5.0 to desired interval
                .autoconnect()
                .sink { _ in
                    Task {
                        await guideProcessor.getDetections()
                        speech.say(text: guideProcessor.textForSpeech)
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
