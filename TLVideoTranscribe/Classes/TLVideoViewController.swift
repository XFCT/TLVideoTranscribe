//
//  TLVideoViewController.swift
//  TLVideoTranscribe
//
//  Created by 王天龙 on 2020/4/8.
//  Copyright © 2020 hogoCloud. All rights reserved.
//

import UIKit
import AVFoundation

let SCREEN_WDITH  = UIScreen.main.bounds.width

let SCREEN_HEIGHT = UIScreen.main.bounds.height

@available(iOS 10.0, *)
class TLVideoViewController: UIViewController, AVCaptureAudioDataOutputSampleBufferDelegate {

    lazy var videoQueue = DispatchQueue.global()
    lazy var audioQueue = DispatchQueue.global()
    lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
    ///视频输入input
    var videoInput:AVCaptureDeviceInput?
    
    var session:AVCaptureSession!

    //照片输出流
    var capturePhotoOutput:AVCapturePhotoOutput!
    ///设备朝向
    var shootingOrientation:UIDeviceOrientation!
    
    var recordView:TLRecordView!
    
    var centerWhiteView : UIView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white

        //初始化
        self.setupSession()
        
        //返回按钮
       let backButton = UIButton(type: .custom)
       backButton.setImage(UIImage(named: "back"), for: .normal)
       view.addSubview(backButton)
       backButton.frame = CGRect(x: 80, y: SCREEN_HEIGHT-80, width: 30, height: 30)
       backButton.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
//       backButton.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height-80)
        
        //切换摄像头
        let switchbutton = UIButton(type: .custom)
        view.addSubview(switchbutton)
        switchbutton.setImage(UIImage(named: "cameraAround"), for: .normal)
        switchbutton.frame = CGRect(x: SCREEN_WDITH-50, y: 30, width: 30, height: 30)
        switchbutton.addTarget(self, action: #selector(switchbuttonClick), for: .touchUpInside)
        
        self.recordView = TLRecordView.init(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        self.view.addSubview(self.recordView)
        self.recordView.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height-80)
        self.recordView.clipsToBounds = true
        self.recordView.layer.cornerRadius = self.recordView.bounds.size.width/2.0
        
        self.centerWhiteView = UIView()
        self.centerWhiteView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.centerWhiteView.center = CGPoint(x: self.recordView.bounds.size.width/2.0, y: self.recordView.bounds.size.height/2.0)
        self.centerWhiteView.layer.cornerRadius = self.centerWhiteView.bounds.size.width/2.0
        self.recordView.addSubview(self.centerWhiteView)
        self.centerWhiteView.backgroundColor = .white
        
        //给录制按钮添加长按收拾和点击拍照
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(takePhoto))
        self.recordView.addGestureRecognizer(tap)
        
    }
    
    /**
    *
    * 1、核心是自定义相机
    *      1> 初始化捕捉设备 AVCaptureSession - 会话
    *      2> 对设备进行设置，例如分辨率等
    *      3> 获取硬件设备，摄像头 - AVCaptureDevice
    *    ps: 4> 这里需要录制视频，所以还要加上获取音频设备 - audioCaptureDevice
    *      5> AVCaptureDeviceInput - 初始化设备输入
    *      6> 初始化设备输出  -  AVCaptureMovieFileOutput
    *    ps: 可以设置 防抖设置、 图层等
    *      7> 设备输入、输出添加到会话
    *    PS: 想要设置对焦、录制视频，需要给设备增加通知，实时监听捕捉画面的移动！
    */
    
    // MARK: - 初始化捕捉设备session
    func setupSession(){
        self.session  = AVCaptureSession()
         //设置分辨率 (设备支持的最高分辨率)
        if self.session.canSetSessionPreset(AVCaptureSession.Preset.high) {
            self.session.sessionPreset = .high
        }
        
        //视频的输入和输出
        let devices = AVCaptureDevice.devices()
        guard let device = devices.filter({$0.position == .back }).first else {
            print("摄像头不可用")
            return
        }
        guard let videoInput =  try? AVCaptureDeviceInput(device: device) else {
            return
        }
        self.videoInput = videoInput
        ///视频输入流
        self.session.addInput(self.videoInput!)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        ///视频输出流
        self.session.addOutput(videoOutput)
        
        //照片流输出
        self.capturePhotoOutput = AVCapturePhotoOutput.init()
        if self.session.canAddOutput(self.capturePhotoOutput) {
            self.session.addOutput(self.capturePhotoOutput)
        }
        
        //
        
        //预览
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
        
        //音频的输入和输出
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            return
        }
        guard let audicInput =  try? AVCaptureDeviceInput(device: audioDevice) else {
                return
            }
        self.session.addInput(audicInput)
        let audioOutput = AVCaptureAudioDataOutput()
        audioOutput.setSampleBufferDelegate(self, queue: audioQueue)
        self.session.addOutput(audioOutput)
        
        
        self.session.startRunning()
    }
    
    @objc func buttonClick (){
        self.dismiss(animated: true, completion: nil)
    }
    ///拍摄照片
    @objc func takePhoto() {
//        let captureConnection = self.capturePhotoOutput.connection(with: AVMediaType.video)
        ///使用
        let capturePhotoSettings = AVCapturePhotoSettings.init()
        capturePhotoSettings.flashMode = .off
        self.capturePhotoOutput.capturePhoto(with: capturePhotoSettings, delegate: self)
        
    }
    //切换摄像头
    @objc func switchbuttonClick(){
        //获取之前的镜头
        guard  var position = videoInput?.device.position else{return}
        //获取当前应该显示的镜头(切换)
         position = position == .front ? .back : .front
        //根据当前镜头创建新的device
        let devices = AVCaptureDevice.devices(for: .video) as [AVCaptureDevice]
        guard let  device = devices.filter({$0.position == position}).first else{return}
        //根据新的device创建新的input
          guard let videoInput =  try? AVCaptureDeviceInput(device: device) else {return}
        //在session种切换input
        self.session.beginConfiguration()
        self.session.removeInput(self.videoInput!)
        self.session.addInput(videoInput)
        self.session.commitConfiguration()
        self.videoInput = videoInput
        
        
    }
}

extension TLVideoViewController:AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
         print("采集")
    }
    
}
//拍照
extension TLVideoViewController:AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let data = photo.fileDataRepresentation()
        let image = UIImage.init(data: data!)
        
    }
}



