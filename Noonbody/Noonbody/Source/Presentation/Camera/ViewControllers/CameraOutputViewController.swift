//
//  CameraOutputViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/04.
//

import UIKit
import AVFoundation

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
        $0.contentMode = .scaleAspectFit
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
    lazy var dateLabel = UILabel().then {
        $0.font = .nbFont(ofSize: 24, weight: .bold, type: .gilroy)
        $0.textColor = .white
    }
    private lazy var meridiemLabel = UILabel().then {
        $0.font = .nbFont(ofSize: 24, weight: .bold, type: .gilroy)
        $0.textColor = .white
    }
    private lazy var pickerView = NBDatePicker().then {
        $0.isUserInteractionEnabled = false
        $0.isHidden = true
        $0.delegate = self
    }
    
    // MARK: - Properties
    
    private let requestManager = CameraRequestManager.shared
    private var viewModel = CameraViewModel()
    private let camera = Camera.shared
    lazy var metaDataArray: [String] = [] {
        didSet {
            pickerView.setMetaDataTime(dataArray: metaDataArray)
        }
    }
    
    // MARK: - View Life Cyle
    
    init(image: UIImage,
         day: String,
         time: String) {
        super.init(nibName: nil, bundle: nil)
        
        photoOutputImageView.image = image
        dateLabel.text = day
        meridiemLabel.text = time
        metaDataArray = day.split(separator: ".").map { String($0) } + time.split(separator: ":").map { String($0) }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
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
        partSegmentedControl.delegate = self
    }
    
    private func initSegementData() {
        let segmentControls = [partAndTimeSegmentedControl: ["부위 선택", "시간 입력"],
                                 photoTimeSegemntedControl: ["사진 시간", "현재 시간", "직접 입력"],
                                      partSegmentedControl: ["전신", "상체", "하체"]]
        
        for segmentControl in segmentControls {
            for (index, title) in segmentControl.value.enumerated() {
                segmentControl.key.setTitle(at: index, title: title)
                if segmentControl.key == partSegmentedControl {
                    segmentControl.key.setImage(at: 0, image: Asset.Image.whole.image)
                    segmentControl.key.setImage(at: 1, image: Asset.Image.upper.image)
                    segmentControl.key.setImage(at: 2, image: Asset.Image.lower.image)
                }
            }
        }
    }
    
    private func mergeLabelToImage() {
        requestManager.image = containerView.renderToImageView()
        
        if UserManager.saveBulitInInLibrary {
            UIImageWriteToSavedPhotosAlbum(containerView.renderToImageView(), nil, nil, nil)
        }
    }
    
    private func getPickerViewTime() -> String {
        if let date = dateLabel.text, !date.isEmpty {
            let dateArray = date.split(separator: ".").map { String($0) }
            let (year, month, day) = (dateArray[0], dateArray[1], dateArray[2])
            if let hour = meridiemLabel.text, !hour.isEmpty {
                let timeArray = hour.replacingOccurrences(of: "AM", with: "")
                                    .replacingOccurrences(of: "PM", with: "")
                                    .split(separator: ":").map { String($0) }
                let (hour, minute) = (timeArray[0], timeArray[1])
                
                let dateString: String = "\(year)-\(month)-\(day)\(hour):\(minute):00"
                
                return dateString
            }
        }
        return String()
    }
    
    func setLibraryImage(image: UIImage) {
        photoOutputImageView.image = image
    }
    
    // MARK: - Actions
    
    @objc
    func pushToNext() {
        mergeLabelToImage()
        requestManager.takenAt = getPickerViewTime()
        let viewController = AlbumSelectionViewController()
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
                                 photoTimeSegemntedControl,
                                 pickerView)
        containerView.addSubviews(photoOutputImageView, dateLabel, meridiemLabel)
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
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(photoOutputImageView.snp.bottom).offset(12)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(partAndTimeSegmentedControl.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        partSegmentedControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(9)
            $0.height.equalTo(92)
        }
        
        photoTimeSegemntedControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(partAndTimeSegmentedControl.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(photoOutputImageView.snp.bottom).inset(12)
        }
        
        meridiemLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(photoOutputImageView.snp.bottom).inset(12)
        }
        
        pickerView.snp.makeConstraints {
            $0.top.equalTo(photoTimeSegemntedControl.snp.bottom).offset(22)
            $0.width.equalTo(300)
            $0.height.equalTo(100)
            $0.centerX.equalToSuperview()
        }
        
    }
    
}

// MARK: - NBSegementedControlDelegate

extension CameraOutputViewController: NBSegmentedControlDelegate {
    
    func changeToIndex(_ segmentControl: NBSegmentedControl, at index: Int) {
        if segmentControl == partAndTimeSegmentedControl {
            switch index {
            case 0:
                showPartComponents()
                hidePhotoComponents()
            case 1:
                hidePartComponents()
                showPhotoComponents()
            default:
                return
            }
        } else if segmentControl == photoTimeSegemntedControl {
            switch Time.init(rawValue: index) {
            case .photo:
                pickerView.setMetaDataTime(dataArray: metaDataArray)
                pickerView.isUserInteractionEnabled = false
                pickerView.reloadPickerView()
                return
            case .current:
                pickerView.setCurrnetTime()
                pickerView.isUserInteractionEnabled = false
                pickerView.reloadPickerView()
                return
            case .custom:
                pickerView.isUserInteractionEnabled = true
                pickerView.reloadPickerView()
                return
            default:
                return
            }
        } else if segmentControl == partSegmentedControl {
            switch Part.init(rawValue: index) {
            case .whole:
                requestManager.bodyPart = "whole"
                return
            case .upper:
                requestManager.bodyPart = "upper"
                return
            case .lower:
                requestManager.bodyPart = "lower"
                return
            default:
                return
            }
        }
    }
    
    private func hidePartComponents() {
        partSegmentedControl.isHidden = true
        photoTimeSegemntedControl.isHidden = false
        descriptionLabel.isHidden = true
    }
    
    private func showPartComponents() {
        partSegmentedControl.isHidden = false
        photoTimeSegemntedControl.isHidden = true
        descriptionLabel.isHidden = false
    }
    
    private func hidePhotoComponents() {
        pickerView.isHidden = true
    }
    
    private func showPhotoComponents() {
        pickerView.isHidden = false
    }
}

extension CameraOutputViewController: DatePickerDelegate {
    
    func pickerViewSelected(_ dateArray: [String]) {
        dateLabel.text = "\(dateArray[0]).\(dateArray[1]).\(dateArray[2])"
        
        guard let hour = Int(dateArray[3]) else { return }
        if hour < 12 {
            meridiemLabel.text = "AM \(dateArray[3]):\(dateArray[4])"
        } else {
            let hourString = "\(hour - 12)".convertTo2Digit()
            meridiemLabel.text = "PM \(hourString):\(dateArray[4])"
        }
    }
    
}
