//
//  FaceTrackerAR.swift
//  ARVideoPlayer
//
//  Created by Gualtiero Frigerio on 20/02/21.
//

import ARKit
import Combine

class FaceTrackerAR: UIViewController {
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
    
    private var isTracking = false
    private let session: ARSession
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
        
        if faceAnchor.isTracked == true && isTracking == false {
            isTracking = true
            status = .faceDetected
        } else if faceAnchor.isTracked == false && isTracking == true {
            isTracking = false
            status = .noFaceDetected
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
