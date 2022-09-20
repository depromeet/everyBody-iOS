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
import Mixpanel

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
    private let mainSegementControl = NBSegmentedControl(buttonStyle: .basic,
                                                                 numOfButton: 3)
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
    private lazy var weightLabel = UILabel().then {
        $0.font = .nbFont(ofSize: 30, weight: .bold, type: .pretendard)
        $0.textColor = .white
    }
    private lazy var dateLabel = UILabel().then {
        $0.font = .nbFont(ofSize: 14, weight: .bold, type: .gilroy)
        $0.textColor = .white
        $0.addShadow(offset: CGSize(width: 0, height: 0), radius: 10)
    }
    private lazy var meridiemLabel = UILabel().then {
        $0.font = .nbFont(ofSize: 14, weight: .bold, type: .gilroy)
        $0.textColor = .white
        $0.addShadow(offset: CGSize(width: 0, height: 0), radius: 10)
    }
    private lazy var takenAtPickerView = NBDatePicker().then {
        $0.isUserInteractionEnabled = false
        $0.isHidden = true
        $0.delegate = self
    }
    private lazy var weightPickerView = UIPickerView().then {
        $0.isHidden = true
        $0.delegate = self
        $0.dataSource = self
    }
    private lazy var decimalWeightPickerView = UIPickerView().then {
        $0.isHidden = true
        $0.delegate = self
        $0.dataSource = self
    }
    private lazy var weightSwitch = NBSwitch(width: 38, height: 24).then {
        $0.type = .basic
        $0.setOffColor(color: Asset.Color.gray30.color)
        $0.delegate = self
        $0.isHidden = true
    }
    private lazy var weightOptionLabel = UILabel().then {
        $0.font = .nbFont(ofSize: 14, weight: .semibold, type: .pretendard)
        $0.text = "몸무게 입력"
        $0.isHidden = true
    }
    private lazy var weightDisableView = UIView().then {
        $0.backgroundColor = .white
        $0.isHidden = true
        $0.alpha = 0.7
    }
    
    // MARK: - Properties
    
    private let requestManager = CameraRequestManager.shared
    private var viewModel = CameraViewModel()
    private let camera = Camera.shared
    lazy var metaDataArray: [String] = [] {
        didSet {
            takenAtPickerView.setMetaDataTime(dataArray: metaDataArray)
        }
    }
    private var selectedWeight = ""
    private var selectedDemicalWeight = ""
    private let weightList = (0...250).map { String($0) }
    private let decimalWeightList = (0...9).map { "." + String($0) }
    
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
        
        setinitialPart()
        initNavigationBar()
        setViewHierarchy()
        setLayout()
        initSegmentedControl()
        initSegementData()
        setDefaultWeight()
        initWeightUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isPushed = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !isPushed {
            Mixpanel.mainInstance().track(event: "photo/btn/back")
        }
    }
    
    // MARK: - Methods
    
    private func setinitialPart() {
        requestManager.bodyPart = .whole
    }
    
    private func initNavigationBar() {
        navigationController?.initNaviBarWithBackButton()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(pushToNext))
        title = "사진 확인"
    }
    
    private func initSegmentedControl() {
        mainSegementControl.delegate = self
        photoTimeSegemntedControl.delegate = self
        partSegmentedControl.delegate = self
    }
    
    private func initSegementData() {
        let segmentControls = [mainSegementControl: ["부위 선택", "시간 입력", "몸무게"],
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
    
    private func setLibraryImage(image: UIImage) {
        photoOutputImageView.image = image
    }
    
    private func setDefaultWeight() {
        weightPickerView.selectRow(UserManager.weight, inComponent: 0, animated: false)
        decimalWeightPickerView.selectRow(UserManager.demicalWeight, inComponent: 0, animated: false)
    }

    private func removePickerViewBackgroundColor() {
        DispatchQueue.main.async { [self] in
            [weightPickerView, decimalWeightPickerView]
                .forEach { picker in
                    picker.subviews[1].backgroundColor = .clear
                }
        }
    }
    
    private func initWeightUI() {
        weightSwitch.isOn = UserManager.weightMode
        weightLabel.isHidden = !UserManager.weightMode
        initWeightLabel()
    }
    
    private func initWeightLabel() {
        selectedWeight = "\(UserManager.weight)"
        selectedDemicalWeight = ".\(UserManager.demicalWeight)"
        weightLabel.text = selectedWeight + selectedDemicalWeight + "kg"
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
                                 mainSegementControl,
                                 partSegmentedControl,
                                 descriptionLabel,
                                 photoTimeSegemntedControl,
                                 takenAtPickerView,
                                 weightPickerView,
                                 decimalWeightPickerView,
                                 weightSwitch,
                                 weightOptionLabel,
                                 weightDisableView)
        containerView.addSubviews(photoOutputImageView, weightLabel, dateLabel, meridiemLabel)
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
        
        mainSegementControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(photoOutputImageView.snp.bottom).offset(12)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(mainSegementControl.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        partSegmentedControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(9)
            $0.height.equalTo(92)
        }
        
        photoTimeSegemntedControl.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(mainSegementControl.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        weightLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(dateLabel.snp.top).offset(-10)
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(photoOutputImageView.snp.bottom).inset(24)
        }
        
        meridiemLabel.snp.makeConstraints {
            $0.leading.equalTo(dateLabel.snp.trailing).offset(5)
            $0.bottom.equalTo(photoOutputImageView.snp.bottom).inset(24)
        }
        
        takenAtPickerView.snp.makeConstraints {
            $0.top.equalTo(photoTimeSegemntedControl.snp.bottom).offset(22)
            $0.width.equalTo(300)
            $0.height.equalTo(140)
            $0.centerX.equalToSuperview()
        }
                
        weightSwitch.snp.makeConstraints {
            $0.top.equalTo(mainSegementControl.snp.bottom).offset(8)
            $0.width.equalTo(38)
            $0.height.equalTo(24)
            $0.leading.equalTo(20)
        }
        
        weightOptionLabel.snp.makeConstraints {
            $0.centerY.equalTo(weightSwitch)
            $0.leading.equalTo(weightSwitch.snp.trailing).offset(8)
        }
        
        weightPickerView.snp.makeConstraints {
            $0.top.equalTo(weightSwitch.snp.bottom).offset(5)
            $0.width.equalTo(150)
            $0.height.equalTo(140)
            $0.leading.equalTo(30)
        }
        
        decimalWeightPickerView.snp.makeConstraints {
            $0.top.equalTo(weightSwitch.snp.bottom).offset(5)
            $0.width.equalTo(150)
            $0.height.equalTo(140)
            $0.leading.equalTo(weightPickerView.snp.trailing).offset(5)
        }
        
        weightDisableView.snp.makeConstraints {
            $0.top.equalTo(weightPickerView.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(140)
        }

    }
    
}

extension CameraOutputViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case weightPickerView:
            selectedWeight = weightList[row]
            UserManager.weight = row
        case decimalWeightPickerView:
            selectedDemicalWeight = decimalWeightList[row]
            UserManager.demicalWeight = row
        default:
            return
        }
        
        weightLabel.text = selectedWeight + selectedDemicalWeight + "kg"
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.font = .nbFont(type: .body2SemiBold)
        
        switch pickerView {
        case weightPickerView:
            label.text = weightList[row]
        case decimalWeightPickerView:
            label.text = decimalWeightList[row]
        default:
            return label
        }
        
        label.textAlignment = .center
        return label
    }
}

extension CameraOutputViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case weightPickerView:
            return weightList.count
        case decimalWeightPickerView:
            return decimalWeightList.count
        default:
            return 0
        }
    }
    
}

// MARK: - NBSegementedControlDelegate

extension CameraOutputViewController: NBSegmentedControlDelegate {
    
    func changeToIndex(_ segmentControl: NBSegmentedControl, at index: Int) {
        if segmentControl == mainSegementControl {
            switch index {
            case 0:
                showPartComponents()
                hidePhotoComponents()
                hideWeightComponents()
                Mixpanel.mainInstance().track(event: "photo/tab/selectPart")
            case 1:
                showPhotoComponents()
                hidePartComponents()
                hideWeightComponents()
                Mixpanel.mainInstance().track(event: "photo/tab/inputTime")
            case 2:
                showWeightComponents()
                hidePartComponents()
                hidePhotoComponents()
                Mixpanel.mainInstance().track(event: "photo/tab/inputWeight")
            default:
                return
            }
        } else if segmentControl == photoTimeSegemntedControl {
            switch Time.init(rawValue: index) {
            case .photo:
                takenAtPickerView.setMetaDataTime(dataArray: metaDataArray)
                takenAtPickerView.isUserInteractionEnabled = false
                takenAtPickerView.reloadPickerView()
                Mixpanel.mainInstance().track(event: "photo/btn/photoTime")
                return
            case .current:
                takenAtPickerView.setCurrnetTime()
                takenAtPickerView.isUserInteractionEnabled = false
                takenAtPickerView.reloadPickerView()
                Mixpanel.mainInstance().track(event: "photo/btn/currentTime")
                return
            case .custom:
                takenAtPickerView.isUserInteractionEnabled = true
                takenAtPickerView.reloadPickerView()
                Mixpanel.mainInstance().track(event: "photo/btn/directInput")
                return
            default:
                return
            }
        } else if segmentControl == partSegmentedControl {
            switch Part.init(rawValue: index) {
            case .whole:
                requestManager.bodyPart = .whole
                Mixpanel.mainInstance().track(event: "photo/selectPart/btn/whole")
                return
            case .upper:
                requestManager.bodyPart = .upper
                Mixpanel.mainInstance().track(event: "photo/selectPart/btn/upper")
                return
            case .lower:
                requestManager.bodyPart = .lower
                Mixpanel.mainInstance().track(event: "photo/selectPart/btn/lower")
                return
            default:
                return
            }
        }
    }
    
    private func hidePartComponents() {
        partSegmentedControl.isHidden = true
        descriptionLabel.isHidden = true
    }
    
    private func showPartComponents() {
        partSegmentedControl.isHidden = false
        descriptionLabel.isHidden = false
    }
    
    private func hidePhotoComponents() {
        takenAtPickerView.isHidden = true
        photoTimeSegemntedControl.isHidden = true
    }
    
    private func showPhotoComponents() {
        takenAtPickerView.isHidden = false
        photoTimeSegemntedControl.isHidden = false
    }
    
    private func hideWeightComponents() {
        weightPickerView.isHidden = true
        weightOptionLabel.isHidden = true
        weightSwitch.isHidden = true
        decimalWeightPickerView.isHidden = true
        weightDisableView.isHidden = true
    }
    
    private func showWeightComponents() {
        weightPickerView.isHidden = false
        weightOptionLabel.isHidden = false
        weightSwitch.isHidden = false
        decimalWeightPickerView.isHidden = false
        weightLabel.isHidden = !UserManager.weightMode
        weightDisableView.isHidden = UserManager.weightMode
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

extension CameraOutputViewController: NBSwitchDelegate {
    
    func switchButtonStateChanged(isOn: Bool) {
        UserManager.weightMode = isOn
        weightLabel.isHidden = !isOn
        weightPickerView.isUserInteractionEnabled = isOn
        decimalWeightPickerView.isUserInteractionEnabled = isOn
        weightDisableView.isHidden = isOn
        if isOn {
            Mixpanel.mainInstance().track(event: "photo/inputWeight/toggle/on")
        } else {
            Mixpanel.mainInstance().track(event: "photo/inputWeight/toggle/off")
        }
    }
    
}
