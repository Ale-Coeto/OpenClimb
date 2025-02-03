//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 01/02/25.
//
//
//import Foundation
//import AVFoundation
//import CoreImage
//import CoreImage.CIFilterBuiltins
//import UIKit
//import SwiftUI
//import Combine
//
//
////import AVFoundation
///
import Combine
import UIKit

//@MainActor
class FrameProcessor: ObservableObject {
    @Published var frame1: UIImage?
    private var cancellables = Set<AnyCancellable>()
    private let context = CIContext()
    var centerColor: (red: UInt8, green: UInt8, blue: UInt8)? = nil
    var filterColor: (red: UInt8, green: UInt8, blue: UInt8)? = nil
    var useFilter = false
    let kernel = CIColorKernel(source: kernelCode)
    
    init() {
        let dummyImage = CIImage(color: .black).cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
            _ = context.createCGImage(dummyImage, from: dummyImage.extent)
    }
    
    func setup(framePublisher: PassthroughSubject<CIImage, Never>) {
        framePublisher
            .receive(on: RunLoop.main) // Ensure updates are on the main thread
            .sink { [weak self] frame in
                // Convert the frame to UIImage
                if let uiImage = self?.processImage(frame) {
                   self?.frame1 = uiImage
                    print("image updated")
                }
            }
            .store(in: &cancellables)
    }
    
    func setColor() {
        filterColor = centerColor
        useFilter = true
    }
    
    func resetColor() {
        filterColor = nil
        useFilter = false
    }
    
    private func processImage(_ frame: CIImage) -> UIImage? {
        
        
        
        if let cgImage = context.createCGImage(frame, from: frame.extent) {
            let rgb = getCenterRGBValues(from: cgImage)!
            print(rgb)
            var uiImage = UIImage(cgImage: cgImage)
            
            if useFilter {
                let filteredImage = applyCustomKernel(image: frame, redThreshold: Float(rgb.red), greenThreshold: Float(rgb.green), blueThreshold: Float(rgb.blue))!
                let cg = context.createCGImage(filteredImage, from: filteredImage.extent)
                uiImage = UIImage(cgImage: cg!)
                print("Used filter")
            }
            
            print("Success")
            return uiImage
        }
        // Implement the conversion from `Frame` to `UIImage` here
        // This is just a placeholder, replace it with your actual conversion logic
        return nil
    }
    
    
    func applyCustomKernel(image: CIImage, redThreshold: Float, greenThreshold: Float, blueThreshold: Float) -> CIImage? {
                    let normalizedRedThreshold = redThreshold / 255.0
                        let normalizedGreenThreshold = greenThreshold / 255.0
                        let normalizedBlueThreshold = blueThreshold / 255.0
//                    guard let kernel = CIColorKernel(source: kernelCode) else {
//                        print("Failed to compile kernel")
//                        return nil
//                    }
    
                    // Pass all parameters to the kernel
                    let arguments: [Any] = [image, normalizedRedThreshold, normalizedGreenThreshold, normalizedBlueThreshold]
                    let outputImage = kernel!.apply(extent: image.extent, arguments: arguments)
    
                    return outputImage
                }
    
    
    func getCenterRGBValues(from cgImage: CGImage) -> (red: UInt8, green: UInt8, blue: UInt8)? {
                // Get the width, height, and bytes per row of the CGImage
                let width = cgImage.width
                let height = cgImage.height
                let bytesPerPixel = 4 // Assuming RGBA
                let bytesPerRow = cgImage.bytesPerRow
    
                // Calculate the center pixel coordinates
                let centerX = width / 2
                let centerY = height / 2
    
                // Ensure the image is valid and has pixel data
                guard let dataProvider = cgImage.dataProvider,
                      let pixelData = dataProvider.data else {
                    print("Failed to access pixel data.")
                    return nil
                }
    
                // Get a raw pointer to the pixel data
                let dataPointer = CFDataGetBytePtr(pixelData)
    
                // Calculate the byte offset for the center pixel
                let offset = (centerY * bytesPerRow) + (centerX * bytesPerPixel)
    
                // Extract RGBA values
                let red = dataPointer![offset]
                let green = dataPointer![offset + 1]
                let blue = dataPointer![offset + 2]
    
                // Return the RGB values (ignoring alpha for this example)
                return (red: red, green: green, blue: blue)
            }
        
}
