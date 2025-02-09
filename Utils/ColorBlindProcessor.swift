//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 03/02/25.
//
//

import Combine
import UIKit

class ColorBlindProcessor: ObservableObject {
    @Published var frame1: UIImage?
    private var cancellables = Set<AnyCancellable>()
    private let context = CIContext()
    var centerColor: (red: UInt8, green: UInt8, blue: UInt8)? = nil
    var filterColor: (red: UInt8, green: UInt8, blue: UInt8)? = nil
    var useFilter = false
    let kernel = CIColorKernel(source: kernelCode)
    var samplingRectangle: CGRect?
    
    init() {
        let dummyImage = CIImage(color: .black).cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
        _ = context.createCGImage(dummyImage, from: dummyImage.extent)
        
    }
    
    func setColor() {
        filterColor = centerColor
        useFilter = true
    }
    
    func resetColor() {
        filterColor = nil
        useFilter = false
    }
    
    func setup(framePublisher: PassthroughSubject<CIImage, Never>) {
        framePublisher
            .compactMap(makeCGImage)
        
            .map(getRGBValues)
        
            .compactMap(applyFilter)
        
            .receive(on: RunLoop.main)
            .sink(receiveValue: setImage)
            .store(in: &cancellables)
    }
    
    private func makeCGImage(_ frame: CIImage) -> (CIImage, CGImage)? {
        if let cgImage = context.createCGImage(frame, from: frame.extent) {
            return (frame, cgImage)
        }
        return nil
    }
    
    private func getRGBValues(_ frame: CIImage, _ cgImage: CGImage) -> (CIImage, CGImage) {
        if samplingRectangle == nil {
            setSamplingRectangle(for: cgImage)
        }
        centerColor = getAverageRGBValues(from: cgImage)!
        return (frame, cgImage)
    }
    
    private func applyFilter(_ frame: CIImage, _ cgImage: CGImage) -> UIImage {
        var uiImage = UIImage(cgImage: cgImage)
        
        if useFilter && filterColor != nil {
            let filteredImage = applyCustomKernel(image: frame, redThreshold: Float(filterColor!.red), greenThreshold: Float(filterColor!.green), blueThreshold: Float(filterColor!.blue))!
            let cg = context.createCGImage(filteredImage, from: filteredImage.extent)
            uiImage = UIImage(cgImage: cg!)
            print("Used filter")
        }
        
        print("Success")
        return uiImage
    }
    
    private func setImage(_ uiImage: UIImage) {
        frame1 = uiImage
    }
    
    
    func applyCustomKernel(image: CIImage, redThreshold: Float, greenThreshold: Float, blueThreshold: Float) -> CIImage? {
        let normalizedRedThreshold = redThreshold / 255.0
        let normalizedGreenThreshold = greenThreshold / 255.0
        let normalizedBlueThreshold = blueThreshold / 255.0
        let arguments: [Any] = [image, normalizedRedThreshold, normalizedGreenThreshold, normalizedBlueThreshold]
        let outputImage = kernel!.apply(extent: image.extent, arguments: arguments)
        return outputImage
    }
    
    
    func getCenterRGBValues(from cgImage: CGImage) -> (red: UInt8, green: UInt8, blue: UInt8)? {
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4 // Assuming RGBA
        let bytesPerRow = cgImage.bytesPerRow
        let centerX = width / 2
        let centerY = height / 2
        
        guard let dataProvider = cgImage.dataProvider,
              let pixelData = dataProvider.data else {
            print("Failed to access pixel data.")
            return nil
        }
        
        let dataPointer = CFDataGetBytePtr(pixelData)
        let offset = (centerY * bytesPerRow) + (centerX * bytesPerPixel)
        let red = dataPointer![offset]
        let green = dataPointer![offset + 1]
        let blue = dataPointer![offset + 2]
        
        return (red: red, green: green, blue: blue)
    }
    
    func setSamplingRectangle(for cgImage: CGImage, regionSize: Int = 20) {
        let width = cgImage.width
        let height = cgImage.height
        let centerX = width / 2
        let centerY = height / 2
        let halfSize = regionSize / 2
        
        let startX = max(centerX - halfSize, 0)
        let endX = min(centerX + halfSize, width - 1)
        let startY = max(centerY - halfSize, 0)
        let endY = min(centerY + halfSize, height - 1)
        
        self.samplingRectangle = CGRect(
            x: startX,
            y: startY,
            width: endX - startX,
            height: endY - startY
        )
    }
    
    
    func getAverageRGBValues(from cgImage: CGImage) -> (red: UInt8, green: UInt8, blue: UInt8)? {
        guard let rectangle = samplingRectangle else {
            print("Sampling rectangle not set.")
            return nil
        }
        
        let bytesPerPixel = 4
        let bytesPerRow = cgImage.bytesPerRow
        
        guard let dataProvider = cgImage.dataProvider,
              let pixelData = dataProvider.data else {
            print("Failed to access pixel data.")
            return nil
        }
        
        let dataPointer = CFDataGetBytePtr(pixelData)
        
        var totalRed = 0
        var totalGreen = 0
        var totalBlue = 0
        var pixelCount = 0
        
        let startX = Int(rectangle.origin.x)
        let startY = Int(rectangle.origin.y)
        let endX = Int(rectangle.origin.x + rectangle.width)
        let endY = Int(rectangle.origin.y + rectangle.height)
        
        for y in startY..<endY {
            for x in startX..<endX {
                let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                totalRed += Int(dataPointer![offset])
                totalGreen += Int(dataPointer![offset + 1])
                totalBlue += Int(dataPointer![offset + 2])
                pixelCount += 1
            }
        }
        
        let avgRed = UInt8(totalRed / pixelCount)
        let avgGreen = UInt8(totalGreen / pixelCount)
        let avgBlue = UInt8(totalBlue / pixelCount)
        
        return (red: avgRed, green: avgGreen, blue: avgBlue)
    }

}

