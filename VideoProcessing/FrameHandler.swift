//
//  File.swift
//  OpenClimb
//
//  Created by Alejandra Coeto on 03/02/25.
//
//  Class that uses AVCaptureSession to read frames from the camera
//  and publish them  with Combine. It also has a video mode to
//  process and publish frames from a video instead of the camera.
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
    @Published var isVideoPlaying = false
    
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
            connection.videoOrientation = .portrait // TODO: update
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
        isVideoPlaying = true
        
        if let url = Bundle.module.url(forResource: "sample", withExtension: "mov") {
            let videoURL = url
            let fileManager = FileManager.default
            
            guard fileManager.fileExists(atPath: videoURL.path) else {
                print("Video file not found at: \(videoURL.path)")
                return
            }
            
            let playerItem = AVPlayerItem(url: videoURL)
            playerItemVideoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: nil)
            playerItem.add(playerItemVideoOutput!)
            player = AVPlayer(playerItem: playerItem)
            player?.play()
            
            displayLink = CADisplayLink(target: self, selector: #selector(readVideoFrame))
            displayLink?.add(to: .main, forMode: .common)
            
            NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        } else {
            print("File not found in Bundle.module")
        }
    }
    
    
    @objc private func readVideoFrame() {
        guard let output = playerItemVideoOutput,
              let itemTime = player?.currentItem?.currentTime(),
              output.hasNewPixelBuffer(forItemTime: itemTime),
              let pixelBuffer = output.copyPixelBuffer(forItemTime: itemTime, itemTimeForDisplay: nil)
        else { return }
        
        var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // For rotation if needed
        //        let rotationTransform = CGAffineTransform(rotationAngle: .pi / 2)
        //        ciImage = ciImage.transformed(by: rotationTransform)
        
        // For flipping vertically if needed
        //        let flipTransform = CGAffineTransform(rotationAngle: .pi)
        //        ciImage = ciImage.transformed(by: flipTransform)
        
        let scaleTransform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        ciImage = ciImage.transformed(by: scaleTransform)
        
        framePublisher.send(ciImage)
    }
    
    @MainActor
    @objc private func videoDidFinish() {
        Task {
            self.mode = .camera
            player?.pause()
            isVideoPlaying = false
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




