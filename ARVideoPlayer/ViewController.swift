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
    
    private func processTrackingStatus(_ value:FaceTrackingStatus) {
        switch value {
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
        let tracker:FaceTracker = FaceTrackerAR.isAvailable() ? FaceTrackerAR() : FaceTrackerAV()
        addChild(tracker)
        tracker.start()
        cancellable = tracker.trackingStatus
            .debounce(for: 1.0,
                          scheduler: RunLoop.main)
            .sink(receiveValue: {[weak self] value in
                self?.processTrackingStatus(value)
        })
    }
    
    
}

