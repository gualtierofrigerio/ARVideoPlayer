//
//  FaceTrackerAV.swift
//  ARVideoPlayer
//
//  Created by Gualtiero Frigerio on 20/02/21.
//

import AVFoundation
import Combine
import UIKit

/// AVFoundation implementation of FaceTracker
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
        
        let session = AVCaptureSession()
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:[.builtInWideAngleCamera],
                                                                      mediaType: AVMediaType.video,
                                                                      position: .front)
        
        guard let captureDevice = deviceDiscoverySession.devices.first,
            let videoDeviceInput = try? AVCaptureDeviceInput(device: captureDevice),
            session.canAddInput(videoDeviceInput)
            else { return }
        session.addInput(videoDeviceInput)
        
        // we're only interested in .face for our recognition
        let objectTypes:[AVMetadataObject.ObjectType] = [.face]
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
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:[.builtInWideAngleCamera],
                                                                      mediaType: AVMediaType.video,
                                                                      position: .front)
        guard let _ = deviceDiscoverySession.devices.first else { return false }
        return true
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
        // a face is detected if at least one metadataObject is of type .face
        let isFaceDetected = metadataObjects.contains(where: { $0.type == .face })
        // I only send updates if the tracking status changed
        // so I always check isTracking alongsside isFaceDetected
        if isFaceDetected == true && isTracking == false {
            isTracking = true
            status = .faceDetected
        } else if isFaceDetected == false && isTracking == true {
            isTracking = false
            status = .noFaceDetected
        }
    }
}
