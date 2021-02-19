//  Copyright (c) 2021, TECHaas.com. All rights reserved.
//
//  ViewController.swift
//  SimpleVPlayer
//
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

    // 回転した時に中身のサイズも変える
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        playerView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        self.playerView.layoutIfNeeded()

        label?.frame = CGRect(x: size.width - 100, y: size.height - 30, width: 50, height: 10)
        self.label?.layoutIfNeeded()
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
        self.playerView.addSubview(label!)

        // 動画のループ再生
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)
    }

    // 動画を最初に巻き戻す
    @objc private func playerItemDidReachEnd(_ notification: Notification) {
        // print("loop")
        self.playerView.player?.currentItem?.seek(to: CMTime.zero, completionHandler: nil)
    }

    // MARK: - Gesture
    // 画面がタップされた時に反応させる
    private func setupGesture() {
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(ViewController.tapped(_:)))

        self.playerView.addGestureRecognizer(tapGesture)
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

    // MARK: - Periodic Time Observer
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

    // MARK: - Player View
    final class PlayerView: UIView {

        // see dev doc. AVPlayerLayer.
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



