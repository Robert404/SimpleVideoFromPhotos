//
//  ViewController.swift
//  TestProject
//
//  Created by Robert Nersesyan on 04.03.23.
//

import UIKit
import CoreML
import SwiftVideoGenerator
import AVFoundation

final class ViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var creatingVideoLabel: UILabel!
    
    // MARK: - Private properties
    
    private var images: [String] = [
        AppConstants.Image.Image1,
        AppConstants.Image.Image2,
        AppConstants.Image.Image3,
        AppConstants.Image.Image4,
        AppConstants.Image.Image5,
        AppConstants.Image.Image6,
        AppConstants.Image.Image7,
        AppConstants.Image.Image8
    ]

    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createVideo()
        activityIndicator.startAnimating()
    }
    
    // MARK: - Private funcs
    
    private func createVideo() {
        
        VideoGenerator.shouldOptimiseImageForVideo = true
        VideoGenerator.videoDurationInSeconds = 30
        
        var imagesRes: [UIImage] = []
        
        guard let firstImage = UIImage(named: images[0]) else { return }
        
        imagesRes.append(firstImage)
        
        for i in 1...images.count - 2 {
            guard let originalImage = UIImage(named: images[i]),
                  let imageWithoutBackground = originalImage.removeBackground(returnResult: .finalImage) else { return }
           
            imagesRes.append(imageWithoutBackground)
            imagesRes.append(originalImage)
           
        }
        generateVideo(images: imagesRes)
    }
    
    private func generateVideo(images: [UIImage]) {
        if let audioURL = Bundle.main.url(forResource: "music", withExtension: "aac") {
            VideoGenerator.current.generate(
                withImages: images,
                andAudios: [audioURL],
                andType: .singleAudioMultipleImage,
                { progress in
                print(progress)
                }) { [weak self] (url) in
                    print(url)
                    switch url {
                    case .success(let success):
                        self?.activityIndicator.stopAnimating()
                        self?.creatingVideoLabel.isHidden = true
                        self?.playVideo(url: success)
                    case .failure(let error):
                        print("Error: \(error)")
                        break
                    }
                }
        }
    }

    private func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        playerLayer.backgroundColor = UIColor.white.cgColor
        self.view.layer.addSublayer(playerLayer)
        player.play()
    }
}



