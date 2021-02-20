//
//  VideoPlayer.swift
//  ARVideoPlayer
//
//  Created by Gualtiero Frigerio on 20/02/21.
//

import AVKit
import UIKit

class VideoPlayer {
    
    func openVideo(atURL url:URL) -> AVPlayerViewController {
        player = AVPlayer(url: url)
        let vc = AVPlayerViewController()
        vc.player = player
        return vc
    }
    
    func pause() {
        player?.pause()
    }
    
    func play() {
        player?.play()
    }
    
    private var player:AVPlayer?
}
