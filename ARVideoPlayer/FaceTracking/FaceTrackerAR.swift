//
//  FaceTrackerAR.swift
//  ARVideoPlayer
//
//  Created by Gualtiero Frigerio on 20/02/21.
//

import ARKit
import Combine

let blinkThreshold:Float = 0.5

/// ARKit implementation of FaceTracker
class FaceTrackerAR: UIViewController {
    // required by FaceTracker protocol
    var trackingStatus: AnyPublisher<FaceTrackingStatus, Never> {
        $status.eraseToAnyPublisher()
    }
    
    init() {
        session = ARSession()
        super.init(nibName: nil, bundle: nil)
        session.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isTracking = false // tracking status
    private let session: ARSession // the ARSession to perform face detection
    // I use a @Published to update status
    @Published private var status:FaceTrackingStatus = .idle
}

// MARK: - FaceTracker

extension FaceTrackerAR: FaceTracker {
    static func isAvailable() -> Bool {
        ARFaceTrackingConfiguration.isSupported
    }
    
    func start() {
        let configuration = ARFaceTrackingConfiguration()
        session.run(configuration, options: [])
    }
    
    func stop() {
        session.pause()
    }
}

// MARK: - ARSessionDelegate

extension FaceTrackerAR: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }
        
        var blinkStatus:BlinkStatus = .none
        // check blink status
        // the values are mirrored, .eyeBlinkLeft is referred to the right eye
        if let leftEyeBlink = faceAnchor.blendShapes[.eyeBlinkLeft] as? Float {
            if leftEyeBlink > blinkThreshold {
                blinkStatus = .rightEye
            }
        }
        if let rightEyeBlink = faceAnchor.blendShapes[.eyeBlinkRight] as? Float {
            if rightEyeBlink > blinkThreshold {
                blinkStatus = blinkStatus == .rightEye ? .bothEyes : .leftEye
            }
        }
        if blinkStatus != .none {
            status = .blink(blinkStatus)
        }
        else { // not blinking so either we detected a face or not
            // I only send updates if the tracking status changed
            // so I always check isTracking alongsside faceAnchor.isTracked
            if faceAnchor.isTracked == true && isTracking == false {
                isTracking = true
                status = .faceDetected
            } else if faceAnchor.isTracked == false && isTracking == true {
                isTracking = false
                status = .noFaceDetected
            }
        }
    }
        
    func sessionWasInterrupted(_ session: ARSession) {
        status = .ended
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        status = .idle
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        status = .error(error)
    }
}
