//
//  ViewController.swift
//  CameraApp
//
//  Created by 田中裕貴 on 2021/04/05.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
  
  var captureSession = AVCaptureSession()
  var mainCamera: AVCaptureDevice?
  var innerCamera: AVCaptureDevice?
  var currentDevice: AVCaptureDevice?
  var photoOutput: AVCapturePhotoOutput?
  var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
  
  @IBOutlet weak var cameraButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCaptureSession()
    setupDevice()
    setupInputOutput()
    setupPreviewLayer()
    captureSession.startRunning()
    styleCaptureButton()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func cameraButton_TouchUpInside(_ sender: Any) {
    let settings = AVCapturePhotoSettings()
    settings.flashMode = .auto
    //settings.isAutoStillImageStabilizationEnabled = true
    self.photoOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
  }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    if let imageData = photo.fileDataRepresentation() {
      let uiImage = UIImage(data: imageData)
      UIImageWriteToSavedPhotosAlbum(uiImage!, nil, nil, nil)
    }
  }
}

extension ViewController {
  
  func setupCaptureSession() {
    captureSession.sessionPreset = AVCaptureSession.Preset.photo
  }
  // デバイスの設定
  func setupDevice() {
    // カメラデバイスのプロパティ設定
    let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
    // プロパティの条件を満たしたカメラデバイスの取得
    let devices = deviceDiscoverySession.devices
    
    for device in devices {
      if device.position == AVCaptureDevice.Position.back {
        mainCamera = device
      } else if device.position == AVCaptureDevice.Position.front {
        innerCamera = device
      }
    }
    // 起動時のカメラを設定
    currentDevice = mainCamera
  }
  
  func setupInputOutput() {
    do {
      let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
      captureSession.addInput(captureDeviceInput)
      photoOutput = AVCapturePhotoOutput()
      photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
      captureSession.addOutput(photoOutput!)
    } catch {
      print(error)
    }
  }
  
  func setupPreviewLayer() {
    cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
    cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
    cameraPreviewLayer?.frame = view.frame
    view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
  }
  
  func styleCaptureButton() {
    cameraButton.layer.borderColor = UIColor.white.cgColor
    cameraButton.layer.borderWidth = 5
    cameraButton.clipsToBounds = true
    cameraButton.layer.cornerRadius = min(cameraButton.frame.width, cameraButton.frame.height) / 2
  }
}


