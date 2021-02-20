//
//  FaceTrackerAV.swift
//  ARVideoPlayer
//
//  Created by Gualtiero Frigerio on 20/02/21.
//

import AVFoundation
import Combine
import UIKit

class FaceTrackerAV: UIViewController {
    var trackingStatus: AnyPublisher<FaceTrackingStatus, Never> {
        $status.eraseToAnyPublisher()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private var captureSession:AVCaptureSession?
    private var isTracking = false
    private var queue:DispatchQueue = DispatchQueue(label: "FaceTrackerAV")
    @Published private var status:FaceTrackingStatus = .idle
    
    private func configureCaptureSession() {
        if captureSession != nil {
            return
        }
        let objectTypes:[AVMetadataObject.ObjectType] = [.face]
        let session = AVCaptureSession()
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:[.builtInWideAngleCamera],
                                                                      mediaType: AVMediaType.video,
                                                                      position: .front)
        
        guard let captureDevice = deviceDiscoverySession.devices.first,
            let videoDeviceInput = try? AVCaptureDeviceInput(device: captureDevice),
            session.canAddInput(videoDeviceInput)
            else { return }
        session.addInput(videoDeviceInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        session.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: queue)
        metadataOutput.metadataObjectTypes = objectTypes
        
        captureSession = session
    }
}

// MARK: - FaceTracker

extension FaceTrackerAV: FaceTracker {
    static func isAvailable() -> Bool {
        true // TODO: detect front camera
    }
    func start() {
        configureCaptureSession()
        captureSession?.startRunning()
    }
    
    func stop() {
        captureSession?.stopRunning()
    }
}

// MARK: - AVCapture delegate

extension FaceTrackerAV:AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                               didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection) {
        let isFaceDetected = metadataObjects.contains(where: { $0.type == .face })
        if isFaceDetected == true && isTracking == false {
            isTracking = true
            status = .faceDetected
        } else if isFaceDetected == false && isTracking == true {
            isTracking = false
            status = .noFaceDetected
        }
    }
}
