//
//  FaceTracker.swift
//  ARVideoPlayer
//
//  Created by Gualtiero Frigerio on 19/02/21.
//

import Combine
import UIKit

protocol FaceTracker: UIViewController {
    var trackingStatus:AnyPublisher<FaceTrackingStatus, Never> {get}
    static func isAvailable() -> Bool
    func start()
    func stop()
}
