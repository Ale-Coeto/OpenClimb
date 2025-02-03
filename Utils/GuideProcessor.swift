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
    private var cancellables = Set<AnyCancellable>()
    private let context = CIContext()
    let poseRequest = DetectHumanBodyPoseRequest()
    var model: CoreMLRequest?
    
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
                textForSpeech = results?.description ?? "No results"
                print(textForSpeech)
            } else {
                print("No ciimage")
            }
        }
    }
    
    @MainActor
    func getDetections() async {
        Task {
            if let img = ciImg, let md = model {
                let  results = try? await model?.perform(on: ciImg!)
                print(results ?? " NOP det")
            }
        }
    }
    
    func getPose(_ ciImage: CIImage) async -> CIImage {
        let results = try? await poseRequest.perform(on: ciImage).first
        print(results?.description ?? "nop")
        return ciImage
    }
    
    

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
            .map { [weak self] ciImage -> (UIImage?, CIImage?) in
                // Extract RGB values
                guard let self = self else { return (nil, nil) }
                
                if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                    let uiImage = UIImage(cgImage: cgImage)
                    return (uiImage, ciImage) // Return both UI and CI images
                }
                return (nil, ciImage) // Return CIImage and nil if no UIImage could be created
            }
            .receive(on: RunLoop.main) // Ensure UI updates happen on the main thread
            .sink { [weak self] uiImage, ciImage in
                // Update the published frame
                self?.ciImg = ciImage
                self?.frame = uiImage
//                self?.textForSpeech = "Hello"
            }

            .store(in: &cancellables)
    }
    

    
    
}
