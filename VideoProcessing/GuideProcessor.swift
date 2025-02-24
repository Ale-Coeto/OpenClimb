//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 02/02/25.
//
//  Class to process frames published by the frame handler for colorblind mode.
//  The pipeline obtains the pose throught Vision framework and holds
//  with a trained ml detection model. Then some calculations are made to
//  build a string that contains the description that will be said to the user.
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
    @Published var isProcessing:Bool = false
    @Published var ciImg: CIImage?
    
    private var cancellables = Set<AnyCancellable>()
    private let context = CIContext()
    var speech = Speech()
    let poseRequest = DetectHumanBodyPoseRequest()
    let personRequest = DetectHumanRectanglesRequest()
    var model: CoreMLRequest?
    var armDistance: CGFloat?
    var legDistance: CGFloat?
    var personRectangle: NormalizedRect?
    
    var closestHolds: [Int: [HumanBodyPoseObservation.JointName: [Detection]]] = [
        1: [.leftShoulder: [], .rightShoulder: [], .leftHip: [], .rightHip: []],
        2: [.leftShoulder: [], .rightShoulder: [], .leftHip: [], .rightHip: []]
    ]
    
    init() {
        let dummyImage = CIImage(color: .black).cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
        _ = context.createCGImage(dummyImage, from: dummyImage.extent)
        let detector = try? HoldsDetector(configuration: MLModelConfiguration())
        
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
    
    @MainActor
    func process() async {
        Task {
            isProcessing = true
            if let img = ciImg {
                self.joints = nil
                
                let results = try? await poseRequest.perform(on: img).first
                print(results ?? "NO pOSe")
                if let joints = results?.allJoints() {
                    processJoints(joints)
                }
                
                if let md = model {
                    if let results = try? await md.perform(on: img) {
                        //                    print(results)
                        detections = convertModelDetections(results)
                    }
                }
                
                makeVisualDescription()
                speech.say(text: textForSpeech)
                
            } else {
                print("No ciimage")
            }
            isProcessing = false
        }
    }
    
    func getPointsDistance(_ p1: NormalizedPoint, _ p2: NormalizedPoint) -> CGFloat {
        return hypot(p2.x - p1.x, p2.y - p1.y)
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
    
    private func processPerson(_ person: HumanObservation) {
        self.personRectangle = person.boundingBox
    }
    
    func getDirection(_ pivot: NormalizedPoint, _ hold: NormalizedPoint) -> String {
        let dx = hold.x - pivot.x
        let dy = hold.y - pivot.y
        
        let threshold: CGFloat = 0.1
        
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
        
        let mainJoints: [HumanBodyPoseObservation.PoseJointName] = [
            .leftShoulder, .rightShoulder, .leftHip, .rightHip
        ]
        
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
        
        var jointPositions: [HumanBodyPoseObservation.PoseJointName: NormalizedPoint] = [:]
        for joint in mainJoints {
            if let location = joints[joint]?.location {
                jointPositions[joint] = location
            }
        }
        
        var closestHolds: [HumanBodyPoseObservation.PoseJointName: (hold: Detection, distance: CGFloat, zone: Int)] = [:]
        
        var assignedHolds = Set<UUID>()
        
        for detection in detections {
            let holdCenter = detection.center
            var bestJoint: HumanBodyPoseObservation.PoseJointName?
            var minDistance: CGFloat = .greatestFiniteMagnitude
            var zone = 2
            
            for joint in mainJoints {
                guard let jointPos = jointPositions[joint] else { continue }
                let distance = getPointsDistance(holdCenter, jointPos)
                
                if distance <= closeRadius[joint]! {
                    if distance < minDistance {
                        minDistance = distance
                        bestJoint = joint
                        zone = 1
                    }
                } else if distance <= farRadius[joint]! {
                    if distance < minDistance {
                        minDistance = distance
                        bestJoint = joint
                        zone = 2
                    }
                }
            }
            
            if let bestJoint = bestJoint, !assignedHolds.contains(detection.id) {
                closestHolds[bestJoint] = (hold: detection, distance: minDistance, zone: zone)
                assignedHolds.insert(detection.id)
            }
        }
        
        textForSpeech = ""
        
        for (joint, data) in closestHolds {
            let hold = data.hold
            let description = "There is a \(hold.label) hold \(getDirection(jointPositions[joint]!, hold.center)) of your \(jointDescription(joint)). "
            textForSpeech += description
        }
        
        if textForSpeech.isEmpty {
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
    
    func normalizedToView(_ point: NormalizedPoint, in size: CGSize) -> CGPoint {
        return CGPoint(x: point.x * size.width, y: (1 - point.y) * size.height)
    }
    
    func convertModelDetections(_ results: CoreMLRequest.Result) -> [Detection] {
        var detections: [Detection] = []
        
        guard let observations = results as? [RecognizedObjectObservation] else {
            print("Error: Result is not of type [RecognizedObjectObservation]")
            return detections
        }
        
        for observation in observations {
            if observation.confidence < 0.5 { continue }
            
            guard let label = observation.labels.first?.identifier else { continue }
            
            let boundingBox = observation.boundingBox.cgRect
            
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
    
}
