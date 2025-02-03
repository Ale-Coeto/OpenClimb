//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 20/01/25.
//

import Foundation
import AVFoundation
import CoreImage
//import CoreImage.CIFilterBuiltins
import UIKit
//import SwiftUI
import Combine

//typealias Frame = CMSampleBuffer
//@MainActor
class FrameHandler: NSObject, ObservableObject {
//    @Published var frame: UIImage?
    private var permissionGranted = false
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
//    private let context = CIContext()
//      var centerColor: (red: UInt8, green: UInt8, blue: UInt8)? = nil
//     var filterColor: (red: UInt8, green: UInt8, blue: UInt8)? = nil
//    @ObservedObject var proc = FrameProcessor()
    
//    var useFilter: Bool = false
//    let passthroughSubject = PassthroughSubject<Frame, Never>()
//     var framePublisher: PassthroughSubject<Frame, Never>?
    var framePublisher = PassthroughSubject<CIImage, Never>()
    
//    let cgImagePublisher = PassthroughSubject<CGImage, Never>()
//    var currentOrientation: UIImage.Orientation = UIImage.Orientation.up
    
//    @Published var loading = true
//    @Published var filterIntensity:Float = 0.9
//    @ObservedObject var x = ColorBlindVM()
    
    override init() {
       super.init()
        checkPermission()
       setupSession()
        startSession()
   }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                self.permissionGranted = true
                
            case .notDetermined: // The user has not yet been asked for camera access.
                self.requestPermission()
                
        // Combine the two other cases into the default case
        default:
            self.permissionGranted = false
        }
    }
    
    func requestPermission() {
        // Strong reference not a problem here but might become one in the future.
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }
    
    func setupSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        
        guard permissionGranted else { return }
        
        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera,for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "outputBufferQueue", attributes: .concurrent, autoreleaseFrequency: .inherit))

        captureSession.addOutput(videoOutput)
        if let connection = videoOutput.connection(with: .video) {
                connection.videoOrientation = .portrait // or use .landscapeRight/Left based on your app design
            print("connection.videoOrientation: \(connection.videoOrientation)")
            }
        
//        loading = false

    }
    
    func startSession() {
        print("Start")
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func toggleSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        } else {
            captureSession.startRunning()
        }
    }
    
    

    
}



//extension FrameHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
//    
//    func captureOutput(_ output: AVCaptureOutput,
//                       didOutput frame: Frame,
//                       from connection: AVCaptureConnection) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//        //        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//        // Forward the frame through the publisher.
//        framePublisher.send(frame)
//    }
//}
extension FrameHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//        let context = CIContext()
//        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }

        // Convert CIImage to CGImage
//        Task { @MainActor in

//            currentOrientation = {
//                       switch connection.videoOrientation {
//                       case .portrait: return .up
//                       case .portraitUpsideDown: return .down
//                       case .landscapeRight: return .left
//                       case .landscapeLeft: return .right
//                       @unknown default: return .up
//                       }
//                   }()
            // Publish the raw CGImage
//        print("Frame captured and sent to publisher")
//        proc.process(ciImage)
        framePublisher.send(ciImage)
//        }

    }
}




//
//extension FrameHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
//    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        // Convert the sample buffer to a CGImage on a background thread
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//
//        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer)
//        
//       
////        let filteredImage = applyFilter(to: cameraImage, intens: 0.1) ?? cameraImage
//
//        let context = CIContext()
//        if let cgImage = context.createCGImage(cameraImage, from: cameraImage.extent) {
////            let aa = cameraImage
//            let rgb = getCenterRGBValues(from: cgImage)!
//                
////                    print("Center pixel RGB: R: \(rgb.red), G: \(rgb.green), B: \(rgb.blue)")
////                } else {
////                    print("Failed to get center RGB values.")
////                }
//            
//            let currentOrientation: UIImage.Orientation = {
//                            switch connection.videoOrientation {
//                            case .portrait: return .up // Adjusted for portrait UI
//                            case .portraitUpsideDown: return .down
//                            case .landscapeRight: return .left
//                            case .landscapeLeft: return .right
//                            @unknown default: return .up
//                            }
//                        }()
//            let imageToPublish = UIImage(cgImage: cgImage, scale: 1.0, orientation: currentOrientation)
//            let aa = CIImage(image: imageToPublish)
//
//            Task { @MainActor in
//                centerColor = rgb
////                let a = x.filterIntensity
////                let final = applyFilter(to: aa!, intens: a)
//                var final = aa
//                if useFilter {
//                    if let filterColor = filterColor {
//                        final = applyCustomKernel(image: aa!, redThreshold: Float(filterColor.red), greenThreshold: Float(filterColor.green), blueThreshold: Float(filterColor.blue))
//                    }
//                }
//                let context = CIContext()
//                if let cgFin = context.createCGImage(final!, from: final!.extent) {
//                    self.frame = UIImage(cgImage: cgFin, scale: 1.0, orientation: currentOrientation)
//
//
//                    
//                }
////                let b = aa
////                self.frame = imageToPublish
//            }
//        }
////        
//        func copyImage(image: CIImage) -> CIImage? {
//            return image
//        }
//
//        func applyFilter(to image: CIImage, intens: Float) -> CIImage? {
//            let filter = CIFilter.sepiaTone()
//            filter.inputImage = image
//            filter.intensity = intens
//            return filter.outputImage
//        }
//        
//        func applyCustomKernel(image: CIImage, redThreshold: Float, greenThreshold: Float, blueThreshold: Float) -> CIImage? {
//            let normalizedRedThreshold = redThreshold / 255.0
//                let normalizedGreenThreshold = greenThreshold / 255.0
//                let normalizedBlueThreshold = blueThreshold / 255.0
//            guard let kernel = CIColorKernel(source: kernelCode) else {
//                print("Failed to compile kernel")
//                return nil
//            }
//
//            // Pass all parameters to the kernel
//            let arguments: [Any] = [image, normalizedRedThreshold, normalizedGreenThreshold, normalizedBlueThreshold]
//            let outputImage = kernel.apply(extent: image.extent, arguments: arguments)
//            
//            return outputImage
//        }
//        
//        func getCenterRGBValues(from cgImage: CGImage) -> (red: UInt8, green: UInt8, blue: UInt8)? {
//            // Get the width, height, and bytes per row of the CGImage
//            let width = cgImage.width
//            let height = cgImage.height
//            let bytesPerPixel = 4 // Assuming RGBA
//            let bytesPerRow = cgImage.bytesPerRow
//
//            // Calculate the center pixel coordinates
//            let centerX = width / 2
//            let centerY = height / 2
//
//            // Ensure the image is valid and has pixel data
//            guard let dataProvider = cgImage.dataProvider,
//                  let pixelData = dataProvider.data else {
//                print("Failed to access pixel data.")
//                return nil
//            }
//
//            // Get a raw pointer to the pixel data
//            let dataPointer = CFDataGetBytePtr(pixelData)
//
//            // Calculate the byte offset for the center pixel
//            let offset = (centerY * bytesPerRow) + (centerX * bytesPerPixel)
//
//            // Extract RGBA values
//            let red = dataPointer![offset]
//            let green = dataPointer![offset + 1]
//            let blue = dataPointer![offset + 2]
//
//            // Return the RGB values (ignoring alpha for this example)
//            return (red: red, green: green, blue: blue)
//        }
//    }
//}



