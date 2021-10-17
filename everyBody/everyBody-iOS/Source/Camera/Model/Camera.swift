//
//  Camera.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/13.
//

import UIKit
import AVFoundation

enum CameraType {
    case front
    case back
}

class Camera: NSObject, AVCapturePhotoCaptureDelegate {
    
    // MARK: - Properties
    
    static let shared = Camera()
    
    private var type: CameraType
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
        self.type = cameraMode
        self.gridMode = false
        session = AVCaptureSession()
        output = AVCapturePhotoOutput()
        session.sessionPreset = .photo
    }
    
    // MARK: - Methods
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    self.setUp()
                }
            }
        default:
            return
        }
    }
    
    func setUp() {
        session.beginConfiguration()
        
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            backCamera = device
        } else {
            fatalError("cannot use the back camera")
        }
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            frontCamera = device
        } else {
            fatalError("cannot use the front camera")
        }
        
        guard let backCameraDeviceInput = try? AVCaptureDeviceInput(device: backCamera) else {
            fatalError("cannot set the input with the back camera")
        }
        
        guard let frontCameraDeviceInput = try? AVCaptureDeviceInput(device: frontCamera) else {
            fatalError("cannot set the input with the front camera")
        }
        
        backInput = backCameraDeviceInput
        frontInput = frontCameraDeviceInput
        
        if session.canAddInput(backInput) && session.canAddOutput(output) {
            session.addInput(backInput)
            session.addOutput(output)
        }
        
        session.commitConfiguration()
    }
    
    func switchCameraInput() {
        switch type {
        case .front:
            session.removeInput(frontInput)
            session.addInput(backInput)
            type = .back
        case .back:
            session.removeInput(backInput)
            session.addInput(frontInput)
            type = .front
        }
        
        output.connections.first?.isVideoMirrored = type == .front ? true : false
    }
    
    func gridToggleDidTap() {
        gridMode.toggle()
    }
    
    func takePicture() {
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        savePicture(pictureData: imageData)
    }
    
    func savePicture(pictureData: Data) {
        let image = UIImage(data: pictureData)!
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    // MARK: - Actions
    
    @objc
    func pinchToZoom(_ pinch: UIPinchGestureRecognizer) {
        let device = backInput.device
        
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
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
