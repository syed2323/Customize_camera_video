//
//  ViewController.swift
//  videoRecorder
//
//  Created by Syed Abdul Ahad on 8/29/22.
//

import UIKit
import Foundation
import AVFoundation
import LLSimpleCamera


class ViewController: UIViewController {
    
    var camera: LLSimpleCamera!
    var upperbar: UIView!
    var segmentedControl : UISegmentedControl!
    var errorlabel: UILabel?
    var snapButton: UIButton!
    var switchButton: UIButton!
    var flashButton: UIButton!
    var timerLabel: UILabel!
    var timmer: Timer = Timer()
    var count:Int = 0
    var timerCounting:Bool = false
    var flashStatus : Int = 0
    
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
    @IBOutlet weak var cameraButton: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        self.camera.start()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.setupCamera()
        setUpCameraControl()
    }
   
    
//MARK: - CAMERA SETUP FOR DISPLAY
    func setupCamera(){
        let screenRect = UIScreen.main.bounds
        camera = LLSimpleCamera()
        camera.isVideoEnabled = true
        camera.cameraQuality = (AVCaptureSession.Preset.high).rawValue
        camera.attach(to: self, withFrame: CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height))
        camera.fixOrientationAfterCapture = false;
        camera .onDeviceChange = {[weak self] (camera: LLSimpleCamera!,
                                device: AVCaptureDevice!) -> Void in
            print("device changes")
            if camera.isFlashAvailable() {
                self?.flashButton!.isHidden = false
                if camera.flash == LLCameraFlashOff {
                    self?.flashButton!.isSelected = false
                }else {
                    self?.flashButton!.isSelected = true
                }
            }else {
                self?.flashButton!.isSelected = true
            }
            
        }
        camera.isZoomingEnabled = true
        
    }
//MARK: - CONTROL FOR CAMERA MAIN SCREEN
    
    
    func setUpCameraControl(){
        let screenRect = UIScreen.main.bounds
        
        snapButton = UIButton(type:  .custom)
        let x = screenRect.size.width / 2.0 - 40.0
        let y = screenRect.size.height - 80.0 - 12.0
        snapButton!.frame = CGRect(x: x, y: y, width: 80.0, height: 80.0)
        snapButton!.clipsToBounds = true
        snapButton!.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        snapButton!.layer.cornerRadius = snapButton!.bounds.width / 2.0
        snapButton!.layer.borderColor = UIColor.white.cgColor
        snapButton!.layer.borderWidth = 3.0
        snapButton!.layer.rasterizationScale = UIScreen.main.scale
        snapButton!.layer.shouldRasterize = true
        snapButton!.addTarget(self, action: #selector(snapButtonTapped), for: .touchUpInside)
        self.view.addSubview(snapButton!)
        
        upperbar = UIView()
        upperbar.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        upperbar.frame =   CGRect(x: 0, y: 0, width: 600, height: 60)
        self.view.addSubview(upperbar)
        
        flashButton = UIButton(type: .system)
        flashButton.frame = CGRect(x: 10, y: 15, width: 50.0, height: 50.0)
        flashButton.tintColor = UIColor.white
        flashButton.setImage(UIImage(named: "flash"), for: .normal)
        flashButton.imageEdgeInsets = UIEdgeInsets.init(top: 10.0, left: 10, bottom: 10, right: 10)
        flashButton.addTarget(self, action: #selector(flashButtonTapped), for: .touchUpInside)
        self.upperbar.addSubview(self.flashButton)
        
        segmentedControl = UISegmentedControl(items: ["photo", "video"])
        segmentedControl.selectedSegmentIndex = 0
        let y1 = screenRect.size.height - 14 - 50 - 12.0
        segmentedControl.frame = CGRect(x: 15.0, y: y1, width: 130.0, height: 40.0)
        segmentedControl.tintColor = UIColor.white
        segmentedControl.addTarget(self,action: #selector(segmentedControlValueChanged), for: .touchUpInside)
        segmentedControl.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        self.view.addSubview(segmentedControl)
        
        timerLabel = UILabel()
        timerLabel!.text = "00 : 00 : 00"
       // timerLabel!.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        timerLabel!.textColor = UIColor.white
        timerLabel!.frame =   CGRect(x: screenRect.size.width/2.0 - 38.0, y: 15, width: 44.0 + 46.0, height: 20.0 + 24.0)
        self.upperbar.addSubview(timerLabel)
    }
    
    
//MARK: - SNAP BUTTON CLICK
    @objc  func snapButtonTapped(Button: UIButton){
        //MARK: - FUNCTION WHEN PHOTO IS SELECTED
        if segmentedControl.selectedSegmentIndex == 0 {
            camera.capture({ [weak self] (camera, image, metaData, error) in
                if error == nil {
                    camera?.performSelector(inBackground: #selector(LLSimpleCamera.stop), with: nil)
                    let imageViewController = ImageViewController()
                    imageViewController.image = image
                    self?.present(imageViewController, animated: true, completion: nil)
                }else{
                    debugPrint("error")
                }
                
            })
        }else{
            
            //MARK: - FUNCTION WHEN Video IS SELECTED
            //MARK: IF video start recordings
            if !self.camera.isRecording{
                // MARK: time label
                timerCounting = true
                timerLabel!.textColor = UIColor.red
                //timerLabel!.backgroundColor = UIColor.red.withAlphaComponent(0.6)
                timmer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
                
                // MARK: snap button
                snapButton.isEnabled = false
                snapButton!.layer.borderColor = UIColor.gray.cgColor
                snapButton?.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
                segmentedControl.isHidden = true
                let outputurl = self.applicationDocumentsDirectory()?.appendingPathComponent("Video")?.appendingPathExtension("mov")
                self.camera.startRecording(withOutputUrl: outputurl)
                
                // MARK: stop video button will show after seconds
                let seconds = 4.0
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [self] in
                    snapButton.isEnabled = true
                    snapButton.layer.borderWidth = 6
                    snapButton!.layer.borderColor = UIColor.white.cgColor
                    snapButton?.backgroundColor = UIColor.red.withAlphaComponent(0.8)
                }
                
                // MARK: flash light control
                if flashStatus == 1 {
                    guard let device = AVCaptureDevice.default(for: AVMediaType.video)
                                    else {return}
                    if device.hasTorch {
                                    do {
                                        try device.lockForConfiguration()
                                        if device.torchMode == AVCaptureDevice.TorchMode.on {
                                            device.torchMode = AVCaptureDevice.TorchMode.off
                                            self.flashStatus = 0
                                        } else {
                                           debugPrint("yes im on")
                                        }
                                        device.unlockForConfiguration()
                                    } catch {
                                        print(error)
                                    }
                                }
                }else{
                    guard let device = AVCaptureDevice.default(for: AVMediaType.video)
                                    else {return}
                        do {
                            try device.lockForConfiguration()
                            try device.setTorchModeOn(level: 1.0)
                            self.flashStatus = 1
                        } catch {
                            print(error)
                        }

                }
                }else{
                //MARK: IF video stop recordings
                    
                segmentedControl.isHidden = false
                snapButton.layer.borderColor = UIColor.white.cgColor
                snapButton.backgroundColor = UIColor.white.withAlphaComponent(0.5)
                    self.camera.stopRecording({ [self](camer, outputfile, error)in
                    self.timerCounting = false
                        self.count = 0
                        timerLabel!.textColor = UIColor.white
                   // timerLabel!.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                    self.timmer.invalidate()
                    if error == nil {
                        self.timerLabel.text = "00 : 00 : 00"
                        debugPrint("switching to player screen")
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier: "VideoViewController") as! VideoViewController
                        vc.videoURL = outputfile as NSURL?
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }else{
                        debugPrint("Eroor saving the video \(error)")
                    }
                })
            }
        }
    }
    @objc func segmentedControlValueChanged(control: UISegmentedControl!){
        
    }
    
    @objc func flashButtonTapped(control: UIButton!){
        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
                        else {return}
        if flashStatus == 1{
            flashStatus = 0
            flashButton.setImage(UIImage(named: "flash-off"), for: .normal)
            
        }else{
            flashStatus = 1
            flashButton.setImage(UIImage(named: "flash"), for: .normal)
        }
//        guard let device = AVCaptureDevice.default(for: AVMediaType.video)
//                else {return}
//            if device.hasTorch && flashStatus == 0 {
//                do {
//                    flashButton.setImage(UIImage(named: "flash-off"), for: .normal)
//                    try device.lockForConfiguration()
//                    if device.torchMode == AVCaptureDevice.TorchMode.on {
//                        device.torchMode = AVCaptureDevice.TorchMode.off
//                            //AVCaptureDevice.TorchModeAVCaptureDevice.TorchMode.off
//                        flashButton.setImage(UIImage(named: "flash"), for: .normal)
//                    } else {
//                        do {
//                            try device.setTorchModeOn(level: 1.0)
//
//                        } catch {
//                            print(error)
//                        }
//                    }
//                    device.unlockForConfiguration()
//                } catch {
//                    print(error)
//                }
//            }
    }
    //MARK: - video timer Timer
    @objc func timerCounter() -> Void{
        count = count + 1
        let time =  secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        timerLabel.text = timeString
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int,Int,Int){
        return ((seconds / 3600), ((seconds % 3600) / 60), ((seconds % 3600) % 60))
    }
    
    func makeTimeString(hours:Int, minutes: Int, seconds: Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
       return timeString
    }
    
    
    //MARK: - HELPERS
    func applicationDocumentsDirectory() -> NSURL? {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last as NSURL?
        
    }
    
   
}

