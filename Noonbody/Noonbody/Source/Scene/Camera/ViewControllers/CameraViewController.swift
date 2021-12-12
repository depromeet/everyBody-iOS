//
//  CameraViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/13.
//

import AVFoundation
import UIKit

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
    }
    private lazy var previewView = ViewFinder(camera: camera,
                                              height: Constant.Size.screenWidth * (4.0 / 3.0)).makeUIView()
    private var gridIndicatorView = UIImageView().then {
        $0.image = Asset.Image.gridIndicator.image
    }
    private let poseButtonView = TextWithIconView(icon: Asset.Image.pose.image, title: "포즈")
    private let albumButtonView = TextWithIconView(icon: Asset.Image.photo.image, title: "앨범")
    private let bottomSheetView = BottomSheetView()
    private let toastView = GuideView()
    private let guideImageView = UIImageView()
    
    // MARK: - Properties
    
    private lazy var camera = Camera.shared
    private lazy var hasNotch = UIDevice.current.hasNotch
    lazy var viewModel = PoseViewModel()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkPermission()
        initNavigationBar()
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
        camera.checkPermission()
    }
    
    func initNavigationBar() {
        navigationController?.initNavigationBar(navigationItem: self.navigationItem,
                                                rightButtonImages: [Asset.Image.refresh.image],
                                                rightActions: [#selector(switchCameraMode)])
        title = "사진 촬영"
    }
    
    private func initAttributes() {
        takeButton.makeRoundedWithBorder(radius: takeButton.bounds.height / 2,
                                         color: Asset.Color.keyPurple.color.cgColor, borderWith: 6)
    }
    
    private func addPinchGesture() {
        let pinchRecognizer = UIPinchGestureRecognizer(target: camera.self,
                                                       action: #selector(camera.pinchToZoom(_:)))
        self.previewView.addGestureRecognizer(pinchRecognizer)
    }
    
    private func bind() {
        takeButton.rx
            .tap
            .bind { [self] in
                camera.takePicture()
                let viewController = CameraOutputViewController()
                navigationController?.pushViewController(viewController, animated: false)
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

        gridSwitch.isToggleSubject
            .map { !$0 }
            .bind(to: gridIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
        
        bottomSheetView.indexPathSubject
            .asDriver(onErrorJustReturn: 0)
            .map { Int($0) }
            .drive { [weak self] in
                guard let self = self else { return }
                self.guideImageView.image = self.viewModel.allPose[$0].guideImage
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
    
    // MARK: - Actions
    
    @objc
    private func switchCameraMode() {
        camera.switchCameraInput()
    }
    
    private func moveTop(view: UIView) {
        takeButton.transform = CGAffineTransform(scaleX: 1, y: 1)
    }
    
    private func moveBottom(view: UIView) {
        takeButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        takeButton.center.y += hasNotch ? 30 : 10
    }
    
    private func bottomSheetWillAppear() {
        updateConstraint(height: 226 * Constant.Size.screenHeight / 812)
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
            self.moveBottom(view: self.takeButton)
        }
    }
    
    private func bottomSheetWillDisappear() {
        updateConstraint(height: 0)
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.view.layoutIfNeeded()
            self.moveTop(view: self.takeButton)
        }
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
            $0.top.equalTo(previewView.snp.bottom).offset(hasNotch ? 72 : 20)
            $0.height.equalTo(72 * Constant.Size.screenHeight / 812)
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
