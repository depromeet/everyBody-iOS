//
//  CameraViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/13.
//

import AVFoundation
import UIKit
import PhotosUI

import Then
import SnapKit
import RxCocoa
import RxSwift
import RxGesture

class CameraViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private lazy var takeButton = UIButton()
    private lazy var gridSwitch = CustomSwitch(width: 59, height: 24).then {
        $0.type = .text
        $0.delegate = self
    }
    private var previewView = UIView()
    private lazy var gridIndicatorView = UIImageView().then {
        $0.isHidden = !UserManager.gridMode
        $0.image = Asset.Image.gridIndicator.image
    }
    private let poseButtonView = TextWithIconView(icon: Asset.Image.pose.image, title: "포즈")
    private let albumButtonView = TextWithIconView(icon: Asset.Image.photo.image, title: "앨범")
    private let bottomSheetView = BottomSheetView()
    private let toastView = GuideView()
    private let guideImageView = UIImageView()
    
    // MARK: - Properties
    
    private lazy var camera = Camera.shared
    private lazy var viewModel = CameraViewModel()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkPermission()
        initNavigationBar()
        initGridView()
        setupViewHierarchy()
        setupConstraint()
        addPinchGesture()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        initAttributes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        camera.session.startRunning()
    }
    
    // MARK: - Methods
    
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            camera.setUp()
            previewView = camera.makeCameraLayer()
            camera.cameraDataOutput()
            return
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    self.camera.setUp()
                    self.previewView = self.camera.makeCameraLayer()
                    self.camera.cameraDataOutput()
                }
            }
        default:
            return
        }
    }
    
    private func initNavigationBar() {
        navigationController?.initNavigationBar(navigationItem: self.navigationItem,
                                                rightButtonImages: [Asset.Image.refresh.image],
                                                rightActions: [#selector(switchCameraMode)])
        title = "사진 촬영"
    }
    
    private func initGridView() {
        gridSwitch.isOn = UserManager.gridMode
    }
    
    private func initAttributes() {
        takeButton.makeRoundedWithBorder(radius: takeButton.bounds.height / 2,
                                         color: Asset.Color.keyPurple.color.cgColor, borderWith: 6)
    }
    
    private func addPinchGesture() {
        let pinchRecognizer = UIPinchGestureRecognizer(target: camera.self,
                                                       action: #selector(camera.pinchToZoom(_:)))
        previewView.addGestureRecognizer(pinchRecognizer)
    }
    
    private func bind() {
        takeButton.rx
            .tap
            .bind { [self] in
                takePicture()
            }
            .disposed(by: disposeBag)
        
        bottomSheetView.downButton.rx
            .tap
            .bind { [self] in
                bottomSheetWillDisappear()
            }
            .disposed(by: disposeBag)
        
        poseButtonView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [self] _ in
                bottomSheetWillAppear()
            })
            .disposed(by: disposeBag)

        albumButtonView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.openAlbumLibrary()
            })
            .disposed(by: disposeBag)
        
        bottomSheetView.indexPathSubject
            .asDriver(onErrorJustReturn: 0)
            .map { Int($0) }
            .drive { [weak self] in
                guard let self = self else { return }
                if $0 != 0 {
                    self.guideImageView.image = self.viewModel.allPose[$0 - 1].guideImage
                }
                self.guideImageView.isHidden = $0 == 0 ? true : false
                self.toastView.isHidden = true
            }
            .disposed(by: disposeBag)
    }

    private func updateConstraint(height: CGFloat) {
        bottomSheetView.snp.updateConstraints {
            $0.height.equalTo(height)
        }
    }
    
    private func takePicture() {
        DispatchQueue.global(qos: .background).async {
            self.camera.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }
    
    func getPicture(pictureData: Data) -> UIImage {
        guard let image = UIImage(data: pictureData) else { return UIImage() }
        return image
    }
    
    // MARK: - Actions
    
    private func openAlbumLibrary() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images, .livePhotos])
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        picker.modalPresentationStyle = .overFullScreen
        
        self.present(picker, animated: true, completion: nil)
    }
    
    @objc
    private func switchCameraMode() {
        camera.switchCameraInput()
    }
    
    private func moveTop(view: UIView) {
        takeButton.snp.updateConstraints {
            $0.top.equalTo(self.previewView.snp.bottom).offset(UIDevice.current.hasNotch ? 72 : 20)
            $0.height.equalTo(72 * Constant.Size.screenHeight / Constant.Size.figmaHeight)
        }
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        }
    }
    
    private func moveBottom(view: UIView) {
        takeButton.snp.updateConstraints {
            $0.top.equalTo(self.previewView.snp.bottom).offset(UIDevice.current.hasNotch ? 118 : 60)
            $0.height.equalTo(44 * Constant.Size.screenHeight / Constant.Size.figmaHeight)
        }
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func bottomSheetWillAppear() {
        updateConstraint(height: 226 * Constant.Size.screenHeight / 812)
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
            self.moveBottom(view: self.takeButton)
        }
    }
    
    @objc
    private func bottomSheetWillDisappear() {
        updateConstraint(height: 0)
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
            self.moveTop(view: self.takeButton)
        }
    }
    
}

// MARK: - PHPickerViewControllerDelegate

extension CameraViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if let itemProvider = results.first?.itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                
                if let image = image as? UIImage {
                    itemProvider.loadDataRepresentation(forTypeIdentifier: "public.image") { data, _ in
                        if let data = data {
                            let src = CGImageSourceCreateWithData(data as CFData, nil)!
                            if let metadata = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [String: Any] {
                                let (date, time) = self.viewModel.getCreationDate(metadata: metadata)

                                DispatchQueue.main.async {
                                    let viewController = CameraOutputViewController(image: image,
                                                                                    day: date,
                                                                                    time: time)
                                    self.navigationController?.pushViewController(viewController, animated: true)
                                }
                            }
                        }
                    }
                }
            }
            
        }
        
        picker.dismiss(animated: true)
    }
    
}

// MARK: - View Layout

extension CameraViewController {
    
    private func setupViewHierarchy() {
        view.addSubviews(previewView,
                         poseButtonView,
                         albumButtonView,
                         gridSwitch,
                         toastView,
                         bottomSheetView,
                         takeButton)
        previewView.addSubviews(gridIndicatorView, guideImageView)
    }
    
    private func setupConstraint() {
        previewView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constant.Size.screenWidth * (4.0 / 3.0))
        }
        
        gridIndicatorView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        guideImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        gridSwitch.snp.makeConstraints {
            $0.top.equalTo(previewView.snp.top).offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(59)
            $0.height.equalTo(24)
        }
        
        takeButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(previewView.snp.bottom).offset(UIDevice.current.hasNotch ? 72 : 20)
            $0.height.equalTo(72 * Constant.Size.screenHeight / Constant.Size.figmaHeight)
            $0.width.equalTo(takeButton.snp.height).multipliedBy(1.0)
        }
        
        albumButtonView.snp.makeConstraints {
            $0.top.equalTo(takeButton.snp.top).offset(10)
            $0.trailing.equalTo(takeButton.snp.leading).offset(-56)
            $0.height.equalTo(53)
            $0.width.equalTo(32)
        }
        
        poseButtonView.snp.makeConstraints {
            $0.top.equalTo(takeButton.snp.top).offset(10)
            $0.leading.equalTo(takeButton.snp.trailing).offset(56)
            $0.height.equalTo(53)
            $0.width.equalTo(32)
        }
        
        bottomSheetView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }

        toastView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
            $0.bottom.equalTo(previewView.snp.bottom)
        }
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        let (day, time) = viewModel.getCreationDate(metadata: photo.metadata)
        
        let viewController = CameraOutputViewController(image: getPicture(pictureData: imageData),
                                                        day: day,
                                                        time: time)
        navigationController?.pushViewController(viewController, animated: false)
    }
}

extension CameraViewController: CustomSwitchDelegate {
    
    func switchButtonStateChanged(isOn: Bool) {
        UserManager.gridMode = isOn
        gridIndicatorView.isHidden = !isOn
    }
    
}
