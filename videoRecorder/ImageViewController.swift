//
//  ImageViewController.swift
//  videoRecorder
//
//  Created by Syed Abdul Ahad on 8/30/22.
//

import UIKit

class ImageViewController: UIViewController {

    @IBOutlet weak var imageViewController: UIImageView!
    
    var image: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        imageViewController!.image = image 

    }
}
