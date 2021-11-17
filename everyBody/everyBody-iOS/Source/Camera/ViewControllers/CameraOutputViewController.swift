//
//  CameraOutputViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/04.
//

import UIKit

import RxCocoa
import RxSwift

class CameraOutputViewController: BaseViewController {

    enum Part: Int {
        case whole = 0, upper, lower
    }
    
    enum Time: Int {
        case photo = 0, current, custom
    }
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView().then {
        $0.backgroundColor = .white
        $0.showsVerticalScrollIndicator = false
    }
    private let contentsView = UIView()
    private let containerView = UIView()
    private let photoOutputImageView = UIImageView().then {
        $0.backgroundColor = .black
        $0.contentMode = .scaleAspectFill
    }
    private let partAndTimeSegmentedControl = NBSegmentedControl(buttonStyle: .basic,
                                                                 numOfButton: 2)
    private let photoTimeSegemntedControl = NBSegmentedControl(buttonStyle: .background,
                                                               numOfButton: 3).then {
        $0.isHidden = true
    }
    private let partSegmentedControl = NBSegmentedControl(buttonStyle: .background,
                                                          numOfButton: 3).then {
        $0.spacing = 9
    }
    private let descriptionLabel = UILabel().then {
        $0.text = "해당 부위로 사진이 분류됩니다."
        $0.font = .nbFont(type: .caption1)
        $0.textColor = Asset.Color.gray60.color
    }
    private lazy var dateTimeLabel = UILabel().then {
        $0.font = .nbFont(ofSize: 24, weight: .bold, type: .gilroy)
        $0.textColor = .white
    }
    private lazy var meridiemLabel = UILabel().then {
        $0.font = .nbFont(ofSize: 24, weight: .bold, type: .gilroy)
        $0.textColor = .white
    }
    
    // MARK: - Properties
    
    private var cameraViewModel = CameraViewModel()
    private let camera = Camera.shared
    
    // MARK: - View Life Cyle
    
    override func viewDidLoad() {
        
        bind()
        initNavigationBar()
        setViewHierarchy()
        setLayout()
        initSegmentedControl()
        initSegementData()
    }
    
    // MARK: - Methods
    
    private func initNavigationBar() {
        navigationController?.initNaviBarWithBackButton()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(pushToNext))
        title = "사진 확인"
    }
    
    private func initSegmentedControl() {
        partAndTimeSegmentedControl.delegate = self
        photoTimeSegemntedControl.delegate = self
    }
    
    private func initSegementData() {
        let segmentControls = [partAndTimeSegmentedControl: ["부위 선택", "시간 입력"],
                               photoTimeSegemntedControl: ["사진 시간", "현재 시간", "직접 입력"],
                               partSegmentedControl: ["전신", "상체", "하체"]]
        
        for segmentControl in segmentControls {
            for (index, title) in segmentControl.value.enumerated() {
                segmentControl.key.setTitle(at: index, title: title)
            }
        }
    }
    
    private func bind() {
        camera.outputImageRelay
            .bind(to: photoOutputImageView.rx.image)
            .disposed(by: disposeBag)
        
        cameraViewModel.creationTime
            .bind(to: dateTimeLabel.rx.text)
            .disposed(by: disposeBag)
        
        cameraViewModel.meridiemTime
            .bind(to: meridiemLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func mergeLabelToImage() {
        // TODO: - 갤러리에 이미지 저장, 나중에 환경설정 앱 만들면 갤러리 저장할 지 여부 UserDefault 값에 저장해서 값에 따라 분기처리
        UIImageWriteToSavedPhotosAlbum(containerView.renderToImageView(), nil, nil, nil)
    }
    
    // MARK: - Actions
    
    @objc
    func pushToNext() {
        mergeLabelToImage()
        
        let viewController = FolderSelectionViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Layout

extension CameraOutputViewController {
    
    private func setViewHierarchy() {
        contentsView.addSubviews(containerView,
                                 partAndTimeSegmentedControl,
                                 partSegmentedControl,
                                 descriptionLabel,
                                 photoTimeSegemntedControl)
        containerView.addSubviews(photoOutputImageView, dateTimeLabel, meridiemLabel)
        scrollView.addSubview(contentsView)
        view.addSubview(scrollView)
    }
    
    private func setLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(0)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constant.Size.screenWidth * (4.0 / 3.0))
        }
        
        photoOutputImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentsView.snp.makeConstraints {
            $0.width.height.top.bottom.equalTo(self.scrollView)
        }
        
        partAndTimeSegmentedControl.snp.makeConstraints {
            $0.top.equalTo(photoOutputImageView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(partAndTimeSegmentedControl.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        partSegmentedControl.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(9)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(92)
        }
        
        photoTimeSegemntedControl.snp.makeConstraints {
            $0.top.equalTo(partAndTimeSegmentedControl.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        dateTimeLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(photoOutputImageView.snp.bottom).inset(12)
        }
        
        meridiemLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(photoOutputImageView.snp.bottom).inset(12)
        }
        
    }

}

// MARK: - NBSegementedControlDelegate

extension CameraOutputViewController: NBSegmentedControlDelegate {
    
    func changeToIndex(_ segmentControl: NBSegmentedControl, at index: Int) {
        if segmentControl == partAndTimeSegmentedControl {
            switch index {
            case 0:
                hidePartComponents()
            case 1:
                showPartComponents()
            default:
                return
            }
        } else if segmentControl == photoTimeSegemntedControl {
            switch Time.init(rawValue: index) {
            case .photo:
                return
            case .current:
                return
            case .custom:
                return
            default:
                return
            }
        } else if segmentControl == partSegmentedControl {
            switch Part.init(rawValue: index) {
            case .whole:
                return
            case .upper:
                return
            case .lower:
                return
            default:
                return
            }
        }
    }
        
    func hidePartComponents() {
        partSegmentedControl.isHidden = false
        photoTimeSegemntedControl.isHidden = true
        descriptionLabel.isHidden = false
    }
    
    func showPartComponents() {
        partSegmentedControl.isHidden = true
        photoTimeSegemntedControl.isHidden = false
        descriptionLabel.isHidden = true
    }
}
