//
//  ViewController.swift
//  SimpleVPlayer
//
//  Copyright (c) 2021, TECHaas.com. All rights reserved.
//  Created by Koushi Takahashi on 2021/02/17.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {

    private let playerView = AVPlayerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        playerView.frame = CGRect(x: self.view.frame.origin.x,
                                  y: self.view.frame.origin.y,
                                  width: self.view.frame.width,
                                  height: self.view.frame.height)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)

        // https://www.home-movie.biz/free_movie.html
        //
        guard let path = Bundle.main.path(forResource: "sample", ofType:"mp4") else {
            debugPrint("sample.mp4 not found")
            return
        }
        let url = URL(fileURLWithPath: path)

        // 生成
        self.playerView.player = AVPlayer(url: url)

        // レイヤーの追加
        self.playerView.player?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        self.playerView.setVideoFillMode(mode: AVLayerVideoGravity.resizeAspect.rawValue)
        self.view.addSubview(self.playerView)

        // 再生
        self.playerView.player?.play()
    }

    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        // 動画を最初に巻き戻す
        print("movie reached end")
        self.playerView.player?.currentItem?.seek(to: CMTime.zero, completionHandler: nil)
    }

    final class AVPlayerView: UIView {

        var player: AVPlayer? {
            get {
                let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
                return layer.player
            }
            set(newValue) {
                let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
                layer.player = newValue
            }
        }

        // MARK: - OverrideMethod

        override public class var layerClass: Swift.AnyClass {
            return AVPlayerLayer.self
        }

        // MARK: - Public Method

        /// アスペクト比を維持
        /// - Parameter mode: AVLayerVideoGravity
        func setVideoFillMode(mode: String) {
            let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
            layer.videoGravity = AVLayerVideoGravity(rawValue: mode)
        }
    }
}

