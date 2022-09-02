//
//  VideoViewController.swift
//  videoRecorder
//
//  Created by Syed Abdul Ahad on 9/1/22.
//

import UIKit
import AVFoundation
import AVKit

class VideoViewController: UIViewController {
    
    var player: AVPlayer!
    var playerViewController: AVPlayerViewController!
    var videoURL: NSURL!
    var value: Int = 1
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var uploadButton: UIView!
    
    @IBOutlet weak var cancelButton: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.player = AVPlayer(url: videoURL! as URL)
        self.playerViewController = AVPlayerViewController()
        playerViewController.player = self.player
        playerViewController.view.frame = self.playerView.frame
        
        playerViewController.player?.pause()
        playerViewController.entersFullScreenWhenPlaybackBegins = true
        playerViewController.exitsFullScreenWhenPlaybackEnds = true
       
        self.playerView.addSubview(playerViewController.view)
        self.view.addSubview(uploadButton)
        self.view.addSubview(cancelButton)
        
        
      
        
      
    }
    
    @IBAction func cancelVideo(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btn_uploadVideo(_ sender: Any) {
        print("upload button click")
    }
    

}
