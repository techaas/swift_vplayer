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

    private let playerView = PlayerView()
    var timeObserverToken: Any?
    var label: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlayer()

        setupGesture()

        // 再生
        self.playerView.player?.play()
    }

    // 映像再生
    private func setupPlayer() {
        playerView.frame = CGRect(x: self.view.frame.origin.x,
                                  y: self.view.frame.origin.y,
                                  width: self.view.frame.width,
                                  height: self.view.frame.height)

        // https://www.home-movie.biz/free_movie.html
        //
        guard let url = Bundle.main.url(forResource: "sample", withExtension:"mp4") else {
            debugPrint("file not found")
            return
        }

        // 生成
        self.playerView.player = AVPlayer(url: url)

        // レイヤーの追加
        self.playerView.player?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        self.playerView.setVideoFillMode(mode: AVLayerVideoGravity.resizeAspect.rawValue)
        self.view.addSubview(self.playerView)

        addPeriodicTimeObserver()

        // 時間表示用
        label = UILabel(frame: CGRect(x:self.view.frame.width - 100, y:self.view.frame.height - 30,
                                          width:50, height: 10))
        label?.textAlignment = NSTextAlignment.right;
        label?.font = UIFont.monospacedSystemFont(ofSize: 10, weight: UIFont.Weight.regular)
        label?.textColor = UIColor.white
        self.view.addSubview(label!)

        // 動画のループ再生
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }

    // 画面がタップされた時に反応させる
    private func setupGesture() {
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(ViewController.tapped(_:)))

        self.view.addGestureRecognizer(tapGesture)
    }

    // 画面のタップ
    @objc func tapped(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            if let player = self.playerView.player {
                if (player.rate != 0 && player.error == nil) {
                    print("Pause")
                    player.pause()
                } else {
                    print("Start")
                    player.play()
                }
            }
        }
    }

    // 動画を最初に巻き戻す
    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        // print("loop")
        self.playerView.player?.currentItem?.seek(to: CMTime.zero, completionHandler: nil)
    }

    // MARK: Periodic Time Observer
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.01, preferredTimescale: timeScale)

        timeObserverToken = self.playerView.player?.addPeriodicTimeObserver(forInterval: time,
                                                           queue: .main)
        { [weak self] time in
            // update player transport UI
            DispatchQueue.main.async {
                self?.label?.text = NSString(format: "%.2f s", CMTimeGetSeconds(time)) as String
            }
        }
    }

    func removePeriodicTimeObserver() {
        if let timeObserverToken = self.timeObserverToken {
            self.playerView.player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }


    // see dev doc. AVPlayerLayer.
    final class PlayerView: UIView {

        var player: AVPlayer? {
            get { return playerLayer.player }
            set { playerLayer.player = newValue }
        }

        var playerLayer: AVPlayerLayer {
            return layer as! AVPlayerLayer
        }

        override static var layerClass: AnyClass {
            return AVPlayerLayer.self
        }

        /// アスペクト比を維持
        /// - Parameter mode: AVLayerVideoGravity
        func setVideoFillMode(mode: String) {
            playerLayer.videoGravity = AVLayerVideoGravity(rawValue: mode)
        }
    }
}



