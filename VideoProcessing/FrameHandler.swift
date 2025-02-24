//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 03/02/25.
//

import Foundation
import AVFoundation
import CoreImage
import UIKit
import Combine

enum CaptureMode {
    case camera
    case video
}

class FrameHandler: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    var framePublisher = PassthroughSubject<CIImage, Never>()
    private var permissionGranted = false
    private var player: AVPlayer?
        private var playerItemVideoOutput: AVPlayerItemVideoOutput?
        private var displayLink: CADisplayLink?
    
    @MainActor
    @Published var mode: CaptureMode = .camera {
            didSet {
                switch mode {
                case .camera:
                    startCamera()
                case .video:
                    startVideoPlayback()
                }
            }
        }
    
    override init() {
        super.init()
        checkPermission()
        setupSession()
        startSession()
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.permissionGranted = true
            
        case .notDetermined:
            self.requestPermission()
            
        default:
            self.permissionGranted = false
        }
    }
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }
    
    func setupSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        
        guard permissionGranted else { return }
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "outputBufferQueue", attributes: .concurrent, autoreleaseFrequency: .inherit))
        
        captureSession.addOutput(videoOutput)
        if let connection = videoOutput.connection(with: .video) {
            connection.videoOrientation = .portrait // TODO: change to .videoRotationAngle
            print("connection.videoOrientation: \(connection.videoRotationAngle)")
        }
        
    }
    
    func startSession() {
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
    
    func startCamera() {
            stopVideoPlayback()
            startSession()
        }
    @MainActor
    func startVideoPlayback() {
        stopSession()

        // Access video file from the package bundle using Bundle.module
        if let url = Bundle.module.url(forResource: "sample", withExtension: "mov") {
            print("✅ Found file at: \(url.path)")

            // Use the URL directly from the bundle
            let videoURL = url

            // Create a FileManager instance
            let fileManager = FileManager.default

            // Check if the file exists
            guard fileManager.fileExists(atPath: videoURL.path) else {
                print("❌ Video file not found at: \(videoURL.path)")
                return
            }

            print("✅ Video file found, starting playback...")

            let playerItem = AVPlayerItem(url: videoURL)
            playerItemVideoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: nil)
            playerItem.add(playerItemVideoOutput!)

            player = AVPlayer(playerItem: playerItem)
            
            player?.play()

            displayLink = CADisplayLink(target: self, selector: #selector(readVideoFrame))
            displayLink?.add(to: .main, forMode: .common)

            NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        } else {
            print("❌ File not found in Bundle.module")
        }
    }
    
        
        @objc private func readVideoFrame() {
            guard let output = playerItemVideoOutput,
                      let itemTime = player?.currentItem?.currentTime(),
                      output.hasNewPixelBuffer(forItemTime: itemTime),
                      let pixelBuffer = output.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil)
                else { return }
                
                // Create a CIImage from the pixel buffer
                var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                
                // Apply a 90-degree rotation to fix the initial orientation
                let rotationTransform = CGAffineTransform(rotationAngle: .pi / 2)
                ciImage = ciImage.transformed(by: rotationTransform)
                
                // Apply a 180-degree rotation to fix the upside-down issue
                let flipTransform = CGAffineTransform(rotationAngle: .pi)
                ciImage = ciImage.transformed(by: flipTransform)
                
                // Optionally, scale the image to fix the aspect ratio
                let scaleTransform = CGAffineTransform(scaleX: 1.0, y: 1.0) // Adjust scale as needed
                ciImage = ciImage.transformed(by: scaleTransform)
                
                // Send the transformed image through the publisher
                framePublisher.send(ciImage)
        }
        
    @MainActor
        @objc private func videoDidFinish() {
            Task {
//                DispatchQueue.main.async {
                    self.mode = .camera
                player?.pause()
//                }
            }
        }
        
        func stopVideoPlayback() {
            displayLink?.invalidate()
            displayLink = nil
            player?.pause()
            player = nil
        }
    
    
    
}

extension FrameHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        framePublisher.send(ciImage)
    }
}




