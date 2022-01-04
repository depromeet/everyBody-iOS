//
//  Camera.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/13.
//

import UIKit
import AVFoundation

import RxCocoa
import RxSwift

enum CameraType {
    case front
    case back
}

class Camera: NSObject {
    
    // MARK: - Properties
    
    static let shared = Camera()
    
    private var cameraType: CameraType
    private var gridMode: Bool
    
    var session: AVCaptureSession!
    var backInput: AVCaptureDeviceInput!
    var frontInput: AVCaptureDeviceInput!
    var output: AVCapturePhotoOutput!
    var preview: AVCaptureVideoPreviewLayer!
    var backCamera: AVCaptureDevice!
    var frontCamera: AVCaptureDevice!
    
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 3.0
    var lastZoomFactor: CGFloat = 1.0
    
    // MARK: - Initalizer
    
    init(cameraMode: CameraType = .back) {
        self.cameraType = cameraMode
        self.gridMode = false
    }
    
    // MARK: - Methods
    
    func setUp() {
        session = AVCaptureSession()
        session.beginConfiguration()
        if session.canSetSessionPreset(.photo) {
            session.sessionPreset = .photo
        }
        
        if let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back) {
            backCamera = device
        } else {
            fatalError("cannot use the back camera")
        }
        
        if let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front) {
            frontCamera = device
        } else {
            fatalError("cannot use the front camera")
        }
        
        guard let backCameraDeviceInput = try? AVCaptureDeviceInput(device: backCamera) else {
            fatalError("cannot set the input with the back camera")
        }
        
        backInput = backCameraDeviceInput
        
        if !session.canAddInput(backInput) {
            return
        }
        
        guard let frontCameraDeviceInput = try? AVCaptureDeviceInput(device: frontCamera) else {
            fatalError("cannot set the input with the front camera")
        }
        
        frontInput = frontCameraDeviceInput
        
        if !session.canAddInput(frontInput) {
            return
        }
        
        session.addInput(backInput)
    }
    
    func makeCameraLayer() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Constant.Size.screenWidth, height: 500))
        preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.connection?.videoOrientation = .portrait
        preview.frame = view.frame
        view.layer.insertSublayer(preview, at: 0)
        
        return view
    }
    
    func cameraDataOutput() {
        output = AVCapturePhotoOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        output.connections.first?.videoOrientation = .portrait
        session.commitConfiguration()
        session.startRunning()
    }
    
    func switchCameraInput() {
        switch cameraType {
        case .front:
            session.removeInput(frontInput)
            session.addInput(backInput)
            cameraType = .back
        case .back:
            session.removeInput(backInput)
            session.addInput(frontInput)
            cameraType = .front
        }

        output.connections.first?.isVideoMirrored = (cameraType == .front) ? true : false
    }

    func gridToggleDidTap() {
        gridMode.toggle()
    }

    // MARK: - Actions
    
    @objc
    func pinchToZoom(_ pinch: UIPinchGestureRecognizer) {
        let device = backInput.device

        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom),
                       device.activeFormat.videoMaxZoomFactor)
        }

        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }

        let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)
        
        switch pinch.state {
        case .changed: update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default: break
        }
    }
}
