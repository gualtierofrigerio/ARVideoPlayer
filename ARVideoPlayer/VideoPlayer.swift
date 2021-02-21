//
//  VideoPlayer.swift
//  ARVideoPlayer
//
//  Created by Gualtiero Frigerio on 20/02/21.
//

import AVKit
import UIKit

class VideoPlayer {
    
    func goBackwards() {
        seek(-30.0)
    }
    
    func goForward() {
        seek(30.0)
    }
    
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
    
    private func seek(_ value:Double) {
        guard let player = player,
              let duration = player.currentItem?.duration else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + value
        if newTime < (CMTimeGetSeconds(duration) - value) {
            let timeToGo: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64),
                                              timescale: 1000)
            player.seek(to: timeToGo,
                        toleranceBefore: CMTime.zero,
                        toleranceAfter: CMTime.zero)
        }
    }
    
    private var player:AVPlayer?
}
