//
//  ViewController.swift
//  videoRecorder
//
//  Created by Syed Abdul Ahad on 8/29/22.
//

import UIKit
import Foundation
import AVFoundation


class ViewController: UIViewController {
    
    var camera: LLSimpleCamera!
    var captureSession = AVCaptureSession()
    var backFacingCamera: AVCaptureDevice?
    var frontFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    
    var imageOutput : AVCaptureStillImageOutput?
    var stillimage: UIImage?
    
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    @IBOutlet weak var cameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        let devices  = AVCaptureDevice.devices(for: AVMediaType.video) as!
        [AVCaptureDevice]
        
        for device in devices{
            if device.position == .back {
                backFacingCamera = device
            } else if device.position == .front{
                frontFacingCamera = device
            }
            
        }
        // default device
        currentDevice = backFacingCamera
        
        //configure the seasion with output
        imageOutput = AVCaptureStillImageOutput()
        imageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecType.jpeg]
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            captureSession.addInput(captureDeviceInput)
            captureSession.addOutput(imageOutput!)
            
            // set up camera preview layer
            
            cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            view.layer.addSublayer(cameraPreviewLayer!)
            cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            cameraPreviewLayer?.frame = view.layer.frame
            view.bringSubviewToFront(cameraButton)
            
            captureSession.startRunning()
        }catch let error{
            print{error}
        }
    }
  
   


    @IBAction func start(_ sender: Any) {
//        let videoConnectio = imageOutput?.connection(with: AVMediaType.video)
//
//        imageOutput?.captureStillImageAsynchronously(from: videoConnectio!, completionHandler: { imageDataBuffer, error in
//
//            if let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: imageDataBuffer!, previewPhotoSampleBuffer: imageDataBuffer!) {
//                self.stillimage = UIImage(data: imageData)
//                self.performSegue(withIdentifier: "showPhoto", sender: self)
//            }
//        })
        
        //:MARK: - TAKE A VIDEO
        if !self.camera.recording {
            
        }
    }
    
    override func prepare(for segue : UIStoryboardSegue, sender: Any? ) {
        if segue.identifier == "showPhoto" {
            let imageViewController = segue.destination as! ImageViewController
            imageViewController.image = self.stillimage
        }
    }
    
    func applicationDocumentsDirectory() -> NSURL? {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last as NSURL?
        
    }
    
   
}

