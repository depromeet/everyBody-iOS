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

class CameraViewController: UIViewController {
    
    // MARK: - UI Components
    
    private var previewView = UIView()
    
    private lazy var takeButton = UIButton().then {
        $0.backgroundColor = .white
    }
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private lazy var camera = Camera.shared
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkPermission()
        initNavigationBar()
        initViewFinder()
        setupViewHierarchy()
        setupConstraint()
        addPinchGesture()
        buttonEvent()
    }

    override func viewDidLayoutSubviews() {
        initAttributes()
    }
    
    // MARK: - Methods
    
    private func checkPermission() {
        camera.checkPermission()
    }
    
    private func initNavigationBar() {
        self.navigationController?.initWithRightBarButton(navigationItem: self.navigationItem, rightButtonImage: UIImage(named: "convertModeButton")!, action: #selector(switchCameraMode))
    }
    
    private func initViewFinder() {
        let viewFinder = ViewFinder(camera: self.camera, height: Constant.Size.screenWidth * (4.0 / 3.0))
        previewView = viewFinder.makeUIView()
    }
    
    private func initAttributes() {
        takeButton.makeRoundedWithBorder(radius: takeButton.bounds.height / 2, color: Asset.Color.keyPurple.color.cgColor, borderWith: 6)
    }
    
    private func addPinchGesture() {
        let pinchRecognizer = UIPinchGestureRecognizer(target: camera.self, action: #selector(camera.pinchToZoom(_:)))
        self.previewView.addGestureRecognizer(pinchRecognizer)
    }
    
    // MARK: - Actions
    
    @objc
    private func switchCameraMode() {
        camera.switchCameraInput()
    }
    
    private func buttonEvent() {
        takeButton.rx.tap
            .bind {
                self.camera.takePicture()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - View Layout

extension CameraViewController {
    
    private func setupViewHierarchy() {
        view.addSubviews(previewView, takeButton)
    }
    
    private func setupConstraint() {
        previewView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constant.Size.screenWidth * (4.0 / 3.0))
        }
        
        takeButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(previewView.snp.bottom).offset(70)
            $0.height.equalTo(72)
            $0.width.equalTo(takeButton.snp.height).multipliedBy(1.0)
        }
    }
    
}
