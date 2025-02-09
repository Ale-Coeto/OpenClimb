//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 02/02/25.
//

import Foundation
import UIKit
import Combine
import Vision
import CoreML

class Detection: Identifiable {
    var id = UUID()
    var label: String
    var center: NormalizedPoint
    var width: CGFloat
    var height: CGFloat
    var conf: CGFloat
    
    
    init(label: String, center: NormalizedPoint, width: CGFloat, height: CGFloat, conf: CGFloat) {
        self.label = label
        self.center = center
        self.width = width
        self.height = height
        self.conf = conf
    }

}

class GuideProcessor: ObservableObject {
    @Published var frame: UIImage?
    @Published var textForSpeech: String = ""
    @Published var detections: [Detection]?
    @Published var joints: [HumanBodyPoseObservation.PoseJointName : Joint]?
    private var cancellables = Set<AnyCancellable>()
    private let context = CIContext()
    let poseRequest = DetectHumanBodyPoseRequest()
    var model: CoreMLRequest?
    var armDistance: CGFloat?
    let bodyConnections: [(HumanBodyPoseObservation.PoseJointName, HumanBodyPoseObservation.PoseJointName)] = [
        (.rightShoulder, .rightElbow),
        (.rightElbow, .rightWrist),
        (.leftShoulder, .leftElbow),
        (.leftElbow, .leftWrist),
        (.rightShoulder, .leftShoulder),
        (.rightHip, .rightKnee),
        (.rightKnee, .rightAnkle),
        (.leftHip, .leftKnee),
        (.leftKnee, .leftAnkle),
        (.rightHip, .leftHip),
        (.leftHip, .rightShoulder) // Spine line
    ]
    
//     let model = HoldDetector(configuration: MLModelConfiguration())
    // Create a Core ML request
//    let request = CoreMLRequest(model: model)
//    let model = try? HoldDetector(configuration: defaultConfig)
    
//    let model = CoreMLModelContainer(model: HoldDetector)
//    let holdsRequest = CoreMLRequest(model: model)
    @Published var ciImg: CIImage?
    
    
    init() {
        let dummyImage = CIImage(color: .black).cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
            _ = context.createCGImage(dummyImage, from: dummyImage.extent)
        let detector = try? HoldDetector(configuration: MLModelConfiguration())
        let cont = try? CoreMLModelContainer(model: detector!.model)
         model = CoreMLRequest(model: cont!)
    }
    
//    actor PoseProcessor {
//            func getPose(_ ciImage: CIImage, with poseRequest: DetectHumanBodyPoseRequest) async -> CIImage {
//                let results = try? await poseRequest.perform(on: ciImage).first
//                print(results?.description ?? "nop")
//                return ciImage
//            }
//        }
    @MainActor
    func getPose() async {
        Task {
            if let img = ciImg {
                let results = try? await poseRequest.perform(on: img).first
                if let joints = results?.allJoints() {
                    processJoints(joints)
                    print(joints)
                }
//                textForSpeech = results?.description ?? "No results"
                
            } else {
                print("No ciimage")
            }
        }
    }
    func getPointsDistance(_ p1: NormalizedPoint, _ p2: NormalizedPoint) -> CGFloat {
        return hypot(p2.x - p1.x, p2.y - p1.y) // √((x2 - x1)² + (y2 - y1)²)
    }

    private func processJoints(_ joints: [HumanBodyPoseObservation.PoseJointName : Joint]) {
        if let shoulder = joints[.rightShoulder]?.location, let elbow = joints[.rightElbow]?.location, let wrist = joints[.rightWrist]?.location {
            armDistance = getPointsDistance(shoulder, elbow) + getPointsDistance(elbow, wrist)
        }
        self.joints = joints
    }
    
    func makeVisualDescription() {
        guard let joints = joints, let detections = detections else { return }
        
        
    }
    
    @MainActor
    func getDetections() async {
        Task {
            if let img = ciImg, let md = model {
                if let results = try? await md.perform(on: img) {
//                    print(results)
                    detections = convertModelDetections(results)
                    if let detections {
                        textForSpeech = "I see \(detections.count) holds"
                        print("COUNT: ", detections.count)
                    }
                    
                }
            }
        }
    }
    
     func normalizedToView(_ point: NormalizedPoint, in size: CGSize) -> CGPoint {
        return CGPoint(x: point.x * size.width, y: (1 - point.y) * size.height) // Flip Y-axis
    }
    
    func convertModelDetections(_ results: CoreMLRequest.Result) -> [Detection] {
        var detections: [Detection] = []
        
        guard let observations = results as? [RecognizedObjectObservation] else {
                print("Error: Result is not of type [RecognizedObjectObservation]")
                return detections
            }
//        observations.first.

        for observation in observations {
            // Use the first label as the primary label
            if observation.confidence < 0.5 { continue }
            
            guard let label = observation.labels.first?.identifier else { continue }
            print(label)

            let boundingBox = observation.boundingBox.cgRect

            // Convert observation into Detection
            let detection = Detection(
                label: label,
                center: NormalizedPoint(x: boundingBox.midX, y: boundingBox.midY),
                width: boundingBox.width,
                height: boundingBox.height,
                conf: CGFloat(observation.confidence)
            )

            detections.append(detection)
        }

        return detections
    }
    
    
    
//    func getPose(_ ciImage: CIImage) async -> CIImage {
//        let results = try? await poseRequest.perform(on: ciImage).first
//        print(results?.description ?? "nop")
//        return ciImage
//    }
    

    func setupChain(framePublisher: PassthroughSubject<CIImage, Never>) {
//        let poseProcessor = PoseProcessor()
        framePublisher
            
//            .flatMap { ciImage in
//                // Create a copy of `ciImage` to make it Sendable
//                let ciImageCopy = ciImage.copy() as! CIImage
//                let cgImage - context.createCGImage((ciImage), from: ciImage.extent)
//                    
//                return Future<CIImage, Never> { [weak self] promise in
//                                    guard let self = self else { return }
//                    Task { @MainActor in
//                                        // Call the async function with the copied `ciImage`
//                                        let processedImage = await self.getPose(ciImageCopy)
//                                        promise(.success(processedImage))
//                                    }
//                                }
//                
//            }
//            .map { [weak self] ciImage in
//                // Make a copy of CIImage for safe async usage
//                let copiedImage = ciImage.copy() as! CIImage
//            }
            .compactMap(makeUIandCGImage)
        
            .receive(on: RunLoop.main) // Ensure UI updates happen on the main thread
            .sink(receiveValue: setImages)

            .store(in: &cancellables)
    }
    
    private func makeUIandCGImage(_ ciImage: CIImage) -> (UIImage?, CIImage)? {
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            return (uiImage, ciImage) // Return both UI and CI images
        }
        return (nil, ciImage)
    }
    
    private func setImages(_ uiImage: UIImage?, _ ciImage: CIImage) {
        ciImg = ciImage
        frame = uiImage
    }
    

    
    
}
