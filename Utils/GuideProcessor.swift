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
    var legDistance: CGFloat?
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
    
    let mainJoints: [HumanBodyPoseObservation.PoseJointName] = [
        .leftShoulder,
        .rightShoulder,
        .leftHip,
        .rightHip
    ]
    
    var closestHolds: [Int: [HumanBodyPoseObservation.JointName: [Detection]]] = [
        1: [.leftShoulder: [], .rightShoulder: [], .leftHip: [], .rightHip: []],
        2: [.leftShoulder: [], .rightShoulder: [], .leftHip: [], .rightHip: []]
    ]

    @Published var ciImg: CIImage?
    
    
    init() {
        let dummyImage = CIImage(color: .black).cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
            _ = context.createCGImage(dummyImage, from: dummyImage.extent)
        let detector = try? HoldDetector(configuration: MLModelConfiguration())
        let cont = try? CoreMLModelContainer(model: detector!.model)
         model = CoreMLRequest(model: cont!)
    }

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
        
        if let ankle = joints[.leftAnkle]?.location, let knee = joints[.leftKnee]?.location, let hip = joints[.leftHip]?.location {
            legDistance = getPointsDistance(ankle, knee) + getPointsDistance(knee, hip)
        }
        self.joints = joints
    }
    
    func getDirection(_ pivot: NormalizedPoint, _ hold: NormalizedPoint) -> String {
        let dx = hold.x - pivot.x
        let dy = hold.y - pivot.y

        let threshold: CGFloat = 0.1 // Sensitivity for diagonal classification

        if abs(dx) < threshold && dy < 0 {
            return "top"
        } else if abs(dx) < threshold && dy > 0 {
            return "down"
        } else if abs(dy) < threshold && dx < 0 {
            return "left"
        } else if abs(dy) < threshold && dx > 0 {
            return "right"
        } else if dx < 0 && dy < 0 {
            return "top-left"
        } else if dx > 0 && dy < 0 {
            return "top-right"
        } else if dx < 0 && dy > 0 {
            return "down-left"
        } else if dx > 0 && dy > 0 {
            return "down-right"
        }

        return "unknown"
    }

    
    func makeVisualDescription() {
        guard let joints = joints, let detections = detections, let armDistance = armDistance, let legDistance = legDistance else { return }

        let close_reach: CGFloat = 1.2
        let far_reach: CGFloat = 2.0

        // Predefined main joints for arms and legs
        let mainJoints: [HumanBodyPoseObservation.PoseJointName] = [
            .leftShoulder, .rightShoulder, .leftHip, .rightHip
        ]

        // Define radii dynamically
        let closeRadius: [HumanBodyPoseObservation.PoseJointName: CGFloat] = [
            .leftShoulder: armDistance * 2.0,
            .rightShoulder: armDistance * 2.0,
            .leftHip: legDistance * 1.5,
            .rightHip: legDistance * 1.5
        ]

        let farRadius: [HumanBodyPoseObservation.PoseJointName: CGFloat] = [
            .leftShoulder: armDistance * 3.0,
            .rightShoulder: armDistance * 3.0,
            .leftHip: legDistance * 2.0,
            .rightHip: legDistance * 2.0
        ]

        // Initialize closest holds storage
        closestHolds = [
            1: [.leftShoulder: [], .rightShoulder: [], .leftHip: [], .rightHip: []],
            2: [.leftShoulder: [], .rightShoulder: [], .leftHip: [], .rightHip: []]
        ]

        // Ensure we have valid joint positions
        var jointPositions: [HumanBodyPoseObservation.PoseJointName: NormalizedPoint] = [:]
        for joint in mainJoints {
            if let location = joints[joint]?.location {
                jointPositions[joint] = location
            }
        }

        // Process each detection and categorize it
        for detection in detections {
            let holdCenter = detection.center

            var closestJoint: HumanBodyPoseObservation.PoseJointName?
            var closestDistance: CGFloat = .greatestFiniteMagnitude
            var closestZone: Int = 2 // Default to "far" zone

            for joint in mainJoints {
                guard let jointPos = jointPositions[joint] else { continue }

                let distance = getPointsDistance(holdCenter, jointPos)

                if distance <= closeRadius[joint]!, distance < closestDistance {
                    closestJoint = joint
                    closestDistance = distance
                    closestZone = 1 // Closest hold should be in zone 1
                } else if distance <= farRadius[joint]!, distance < closestDistance {
                    closestJoint = joint
                    closestDistance = distance
                    closestZone = 2 // Otherwise, assign to zone 2
                }
            }

            // Add to closest joint only
            if let closestJoint = closestJoint {
                closestHolds[closestZone]?[closestJoint]?.append(detection)
            }
        }

        // Generate text descriptions dynamically
        textForSpeech = ""
        
        for joint in mainJoints {
            if let closeHolds = closestHolds[1]?[joint], !closeHolds.isEmpty {
                for hold in closeHolds {
                    textForSpeech += "There is a hold \(getDirection(jointPositions[joint]!, hold.center)) of your \(jointDescription(joint)). "
                }
            }
        }
    }
    
    func jointDescription(_ joint: HumanBodyPoseObservation.PoseJointName) -> String {
        switch joint {
            case .leftShoulder: return "left arm"
            case .rightShoulder: return "right arm"
            case .leftHip: return "left leg"
            case .rightHip: return "right leg"
            default: return "body"
        }
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
            } else {
                textForSpeech = ""
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
