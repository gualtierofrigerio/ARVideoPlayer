//
//  ViewController.swift
//  ARVideoPlayer
//
//  Created by Gualtiero Frigerio on 20/02/21.
//

import Combine
import UIKit

class ViewController: UIViewController {
    let videoPlayer = VideoPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func buttonTap(_ sender: Any) {
        guard let videoURL = Bundle.main.url(forResource: "local_video", withExtension: "mp4") else  { return }
        
        let vc = videoPlayer.openVideo(atURL: videoURL)
        present(vc, animated: true)
        startFaceTracking()
    }
    
    func playVideo() {
        videoPlayer.play()
    }
    
    func pauseVideo() {
        videoPlayer.pause()
    }
    
    //MARK: - Private
    
    private var cancellable:AnyCancellable?
    
    private func processBlinkStatus(_ status:BlinkStatus) {
        playVideo()
        switch status {
        case .leftEye:
            videoPlayer.goBackwards()
        case .rightEye:
            videoPlayer.goForward()
        case .bothEyes:
            print("both eyes blink")
        case .none:
            print("no blink")
        }
    }
    
    private func processTrackingStatus(_ value:FaceTrackingStatus) {
        switch value {
        case .blink(let status):
            processBlinkStatus(status)
        case .faceDetected:
            playVideo()
        case .noFaceDetected:
            pauseVideo()
        case .idle:
            print("detection idle")
        case .ended:
            pauseVideo()
            print("detection ended")
        case .error(let error):
            print("error while performing detection \(error)")
        }
    }
    
    private func startFaceTracking() {
        // we use the ARKit version if available
        // or fallback to AVFoundation
        let tracker:FaceTracker = FaceTrackerAR.isAvailable() ? FaceTrackerAR() : FaceTrackerAV()
        // I found out the tracker needs to be a VC added as a child
        // in order to receive updates from ARKit/AVFoundation
        addChild(tracker)
        tracker.start()
        // I use debouce to wait a second before pausing/resuming
        // the video once the face tracking changes
        cancellable = tracker.trackingStatus
            .debounce(for: 1.0,
                          scheduler: RunLoop.main)
            .sink(receiveValue: {[weak self] value in
                self?.processTrackingStatus(value)
        })
    }
    
    
}

