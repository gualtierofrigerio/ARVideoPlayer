//
//  FaceTracker.swift
//  ARVideoPlayer
//
//  Created by Gualtiero Frigerio on 20/02/21.
//

import Combine
import UIKit

/// Protocol describing a Face Tracker
/// shared by the ARKit and AVFoundation implementations
/// I found out the face tracker needs to be view controllers
/// added as child VC in order for their delegates methods to be called
/// that's why the protocol requires UIViewController
protocol FaceTracker: UIViewController {
    /// publisher for FaceTrackignStatus
    /// I use @Published but I couldn't put it in the protocol so I use this AnyPublisher instead
    var trackingStatus:AnyPublisher<FaceTrackingStatus, Never> {get}
    
    /// returns True if the Tracker is available
    /// ARKit face tracker is available only on devices with TrueDepth camera
    static func isAvailable() -> Bool
    /// starts the tracking
    func start()
    /// stops the tracking
    func stop()
}
