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

class GuideProcessor: ObservableObject {
    @Published var frame: UIImage?
    @Published var textForSpeech: String = ""
    @Published var detections: [Detection]?
    @Published var joints: [HumanBodyPoseObservation.PoseJointName : Joint]?
    
    var speech = Speech()
    private var cancellables = Set<AnyCancellable>()
    private let context = CIContext()
    let poseRequest = DetectHumanBodyPoseRequest()
    var model: CoreMLRequest?
    var armDistance: CGFloat?
    var legDistance: CGFloat?
    
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
    
    func setupChain(framePublisher: PassthroughSubject<CIImage, Never>) {
        framePublisher
            .compactMap(makeUIandCGImage)
            .receive(on: RunLoop.main)
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
//    @MainActor
//    func processAll() async {
//        await getDetections()  // Step 1: Get detections
//        await getPose()        // Step 2: Get pose data
//
//        // Step 3: Ensure description is updated after detections & pose are ready
//        DispatchQueue.main.async {
//                self.makeVisualDescription() // Now updates in sync with UI
//                print("SPEECH: ", self.textForSpeech)
//                
//                // Step 4: Trigger speech immediately after text updates
//            self.speech.say(text: self.textForSpeech)
//            }
////        makeVisualDescription()
//        print("Result: ", textForSpeech)
//    }
//    
    @MainActor
    func process() async {
        Task {
            if let img = ciImg {
                self.joints = nil
                
                let results = try? await poseRequest.perform(on: img).first
                if let joints = results?.allJoints() {
                    processJoints(joints)
//                    print("Joints: ", joints)
                }
                
                if let md = model {
                    if let results = try? await md.perform(on: img) {
                        //                    print(results)
                        detections = convertModelDetections(results)
                    }
                }
                
                makeVisualDescription()
                speech.say(text: textForSpeech)
//                textForSpeech = results?.description ?? "No results"
                
            } else {
                print("No ciimage")
            }
        }
    }
//    
//    @MainActor
//    func getPose() async {
//        Task {
//            if let img = ciImg {
//                self.joints = nil
//                let results = try? await poseRequest.perform(on: img).first
//                if let joints = results?.allJoints() {
//                    processJoints(joints)
////                    print("Joints: ", joints)
//                }
////                textForSpeech = results?.description ?? "No results"
//                
//            } else {
//                print("No ciimage")
//            }
//        }
//    }
    
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
            return "above"
        } else if abs(dx) < threshold && dy > 0 {
            return "below"
        } else if abs(dy) < threshold && dx < 0 {
            return "to the left"
        } else if abs(dy) < threshold && dx > 0 {
            return "to the right"
        } else if dx < 0 && dy < 0 {
            return "above to the left"
        } else if dx > 0 && dy < 0 {
            return "above to the right"
        } else if dx < 0 && dy > 0 {
            return "below to the left"
        } else if dx > 0 && dy > 0 {
            return "below to the right"
        }

        return "unknown"
    }

    
    func makeVisualDescription() {
        textForSpeech = ""
        guard let detections = detections else {
            print("No detections")
            textForSpeech = "No holds detected"
            return
        }
        
        guard let joints = joints, let armDistance = armDistance, let legDistance = legDistance else {
            print("No joints, detections or distance")
            textForSpeech = "No person detected"
            return
        }

        let close_arm_reach: CGFloat = 2.0
        let close_leg_reach: CGFloat = 1.5
        let far_arm_reach: CGFloat = 3.0
        let far_leg_reach: CGFloat = 2.0

        // Predefined main joints for arms and legs
        let mainJoints: [HumanBodyPoseObservation.PoseJointName] = [
            .leftShoulder, .rightShoulder, .leftHip, .rightHip
        ]

        // Define radii dynamically
        let closeRadius: [HumanBodyPoseObservation.PoseJointName: CGFloat] = [
            .leftShoulder: armDistance * close_arm_reach,
            .rightShoulder: armDistance * close_arm_reach,
            .leftHip: legDistance * close_leg_reach,
            .rightHip: legDistance * close_leg_reach
        ]

        let farRadius: [HumanBodyPoseObservation.PoseJointName: CGFloat] = [
            .leftShoulder: armDistance * far_arm_reach,
            .rightShoulder: armDistance * far_arm_reach,
            .leftHip: legDistance * far_leg_reach,
            .rightHip: legDistance * far_leg_reach
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
        
        if textForSpeech == "" {
            for joint in mainJoints {
                if let closeHolds = closestHolds[1]?[joint], !closeHolds.isEmpty {
                    for hold in closeHolds {
                        textForSpeech += "There is a hold far \(getDirection(jointPositions[joint]!, hold.center)) of your \(jointDescription(joint)). "
                    }
                }
            }
            
        }
        
        if textForSpeech == "" {
            textForSpeech = "No near holds detected, try moving to a different position"
        }
        
        print("SPEECH: ", textForSpeech)
    }
    
    func jointDescription(_ joint: HumanBodyPoseObservation.PoseJointName) -> String {
        switch joint {
            case .leftShoulder: return "left arm"
            case .rightShoulder: return "right arm"
            case .leftHip: return "left foot"
            case .rightHip: return "right foot"
            default: return "body"
        }
    }

    
//    @MainActor
//    func getDetections() async {
//        Task {
//            if let img = ciImg, let md = model {
//                if let results = try? await md.perform(on: img) {
////                    print(results)
//                    detections = convertModelDetections(results)
////                    if let detections {
////                        textForSpeech = "I see \(detections.count) holds"
////                        print("COUNT: ", detections.count)
////                    }
//                    
//                }
//            } else {
//                textForSpeech = ""
//            }
//        }
//    }
    
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
    

    
    

    
    
}
