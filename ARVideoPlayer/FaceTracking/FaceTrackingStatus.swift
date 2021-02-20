//
//  FaceTrackingStatus.swift
//  ARVideoPlayer
//
//  Created by Gualtiero Frigerio on 20/02/21.
//

/// Describes the status of the Face tracking
enum FaceTrackingStatus {
    case faceDetected // a face is detected
    case noFaceDetected // no face detected
    case idle // the tracker hasn't yet started
    case ended // tracking ended
    case error(Error) // reports an error
}
