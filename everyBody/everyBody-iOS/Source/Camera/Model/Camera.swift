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
    
    var outputImage = UIImage()
    var outputImageRelay = PublishRelay<UIImage>()
    var creationDate = PublishSubject<String>()
    var meridiemTime = PublishSubject<String>()
    var fullDate = PublishSubject<String>()
    
    // MARK: - Initalizer
    
    init(cameraMode: CameraType = .back) {
        self.cameraType = cameraMode
        self.gridMode = false
        session = AVCaptureSession()
        output = AVCapturePhotoOutput()
        session.sessionPreset = .photo
        session.startRunning()
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
        session.startRunning()
        
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

    func takePicture() {
        DispatchQueue.global(qos: .background).async {
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }
    
    func savePicture(pictureData: Data) {
        let image = UIImage(data: pictureData)!
        outputImageRelay.accept(image)
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

extension Camera: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        createDateTime(photo: photo)
        savePicture(pictureData: imageData)
    }
    
    /* __nsdictionaryI 값을 string 형태로 변환 */
    func createDateTime(photo: AVCapturePhoto) {
        let dateString = photo.metadata.filter { dics in
            dics.key == "{TIFF}"
        }.map {
            "\($0.value)"
        }[0].split(separator: ";")[0]
        
        let convertedDate = dateString[dateString.firstIndex(of: "\"")!..<dateString.endIndex]
            .replacingOccurrences(of: "\"", with: "")
        
        let date = AppDate(formattedDate: String(convertedDate.split(separator: " ")[0]), with: ":")
        
        creationDate.onNext(date.getFormattedDate(with: "."))
        meridiemTime.onNext(String(convertedDate.split(separator: " ")[1]))
    }
    
}
