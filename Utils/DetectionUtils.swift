//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 13/02/25.
//

import Foundation
import Vision

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
    (.leftHip, .rightShoulder)
]

let mainJoints: [HumanBodyPoseObservation.PoseJointName] = [
    .leftShoulder,
    .rightShoulder,
    .leftHip,
    .rightHip
]
