//
//  FaceTrackingStatus.swift
//  ARVideoPlayer
//
//  Created by Gualtiero Frigerio on 20/02/21.
//

enum FaceTrackingStatus {
    case faceDetected
    case noFaceDetected
    case idle
    case ended
    case error(Error)
}
