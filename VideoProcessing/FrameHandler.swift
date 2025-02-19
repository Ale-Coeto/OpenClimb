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

class FrameHandler: NSObject, ObservableObject {
    private let captureSession = AVCaptureSession()
    var framePublisher = PassthroughSubject<CIImage, Never>()
    private var permissionGranted = false
    
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
    
}

extension FrameHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        framePublisher.send(ciImage)
    }
}




