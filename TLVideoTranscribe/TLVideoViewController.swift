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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
    
       let button = UIButton(type: .custom)
       view.addSubview(button)
       button.setTitle("开始", for: .normal)
       button.setTitleColor(.blue, for: .normal)
       button.frame = CGRect(x: 50, y: 100, width: 50, height: 30)
       button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        
        let switchbutton = UIButton(type: .custom)
        view.addSubview(switchbutton)
        switchbutton.setTitle("切换摄像头", for: .normal)
        switchbutton.setTitleColor(.blue, for: .normal)
        switchbutton.frame = CGRect(x: SCREEN_WDITH-150, y: 100, width: 100, height: 30)
        switchbutton.addTarget(self, action: #selector(switchbuttonClick), for: .touchUpInside)
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
        self.session.addInput(self.videoInput!)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        self.session.addOutput(videoOutput)
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
       setupSession()
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


