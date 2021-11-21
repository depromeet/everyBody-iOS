//
//  PushSettingViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import UIKit

class PushSettingViewController: BaseViewController {
    
    enum State {
        case selected
        case unselected
    }
    
    // MARK: - UI Components
    
    private let pushSettingLabel = UILabel().then {
        $0.text = "앱 푸시 알림"
        $0.font = .nbFont(type: .body2)
        $0.textColor = Asset.Color.gray80.color
    }
    
    private lazy var pushSwitch = CustomSwitch(width: 38, height: 24)
    
    private let separatorLine = UIView().then {
        $0.backgroundColor = Asset.Color.gray10.color
    }
    
    private let pushSettingContainerView = UIView()
    
    private let timeLabel = UILabel().then {
        $0.text = "시간"
        $0.font = .nbFont(type: .body3)
        $0.textColor = Asset.Color.gray80.color
    }
    
    private let timeContainerView = UIView().then {
        $0.makeRoundedWithBorder(radius: 4,
                                 color: Asset.Color.gray80.color.cgColor,
                                 borderWith: 1)
    }
    
    private let timeSettingLabel = UILabel().then {
        $0.textColor = Asset.Color.gray60.color
        $0.text = "10:30"
    }
    
    private let dayLabel = UILabel().then {
        $0.text = "요일"
        $0.font = .nbFont(type: .body3)
        $0.textColor = Asset.Color.gray80.color
    }
    
    private let dayStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 9
    }
    
    private lazy var dayButtonList: [(UIButton, State)] = [] {
        didSet {
            var isSelectedButton = 0
            dayButtonList.forEach { button in
                if button.1 == .selected { isSelectedButton += 1 }
            }
            saveButton.isEnabled = isSelectedButton > 0 ? true : false
        }
    }
    
    private lazy var saveButton = NBPrimaryButton().then {
        $0.setTitle("저장", for: .normal)
        $0.isEnabled = false
        $0.makeRounded(radius: 28)
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createButtons()
        initNavigationBar()
        setupConstraint()
        addTapGesture()
    }
    
    // MARK: - Methods
    
    private func initNavigationBar() {
        navigationController?.initNaviBarWithBackButton()
        title = "알림 설정"
    }
    
    private func createButtons() {
        ["일", "월", "화", "수", "목", "금", "토"].forEach { day in
            let button = NBDayButton()
            button.setTitle(day, for: .normal)
            button.addTarget(self, action: #selector(self.setAction(sender:)), for: .touchUpInside)
            dayButtonList.append((button, .unselected))
            self.dayStackView.addArrangedSubview(button)
        }
    }
    
    @objc
    private func setAction(sender: UIButton) {
        sender.isSelected.toggle()
        dayButtonList.enumerated().forEach { index, button in
            if button.0 == sender {
                dayButtonList[index].1 = button.1 == .selected ? .unselected : .selected
            }
        }
    }
    
    private func showPushSettingView() {
        pushSettingContainerView.isHidden = false
    }
    
    private func hidePushSettingView() {
        pushSettingContainerView.isHidden = true
    }
    
    // MARK: - Actions
    
    private func addTapGesture() {
        let switchTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                             action: #selector(switchButtonDidTap))
        pushSwitch.addGestureRecognizer(switchTapGesture)
        
        let timeSelectViewGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                                   action: #selector(timeSelectViewDidTap))
        timeContainerView.addGestureRecognizer(timeSelectViewGesture)
    }
    
    @objc
    private func switchButtonDidTap() {
        pushSettingContainerView.isHidden = pushSwitch.isOn ? true : false
        saveButton.isHidden = pushSwitch.isOn ? true : false
    }
    
    @objc
    private func timeSelectViewDidTap() {
        let popUp = PopUpViewController(type: .picker)
        popUp.modalTransitionStyle = .crossDissolve
        popUp.modalPresentationStyle = .overCurrentContext
        popUp.delegate = self
        popUp.initalDate = timeSettingLabel.text?.split(separator: ":").map { String($0) } ?? []
        self.present(popUp, animated: true, completion: nil)
    }
    
}

extension PushSettingViewController: PopUpActionProtocol {
    
    func cancelButtonDidTap(_ button: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func confirmButtonDidTap(_ button: UIButton, textInfo: String) {
        timeSettingLabel.text = textInfo
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - Layout

extension PushSettingViewController {
    
    private func setupConstraint() {
        view.addSubviews(pushSettingLabel,
                         pushSwitch,
                         separatorLine,
                         pushSettingLabel,
                         pushSettingContainerView,
                         saveButton)
        pushSettingContainerView.addSubviews(timeLabel,
                                             timeContainerView,
                                             dayLabel,
                                             dayStackView)
        
        pushSettingLayout()
        setTimeLayout()
        setDayLayout()
        
    }
    
    private func pushSettingLayout() {
        pushSettingContainerView.snp.makeConstraints {
            $0.top.equalTo(separatorLine.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        pushSettingLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(24)
            $0.leading.equalToSuperview().offset(21)
        }
        
        pushSwitch.snp.makeConstraints {
            $0.top.equalTo(pushSettingLabel.snp.top)
            $0.trailing.equalToSuperview().offset(-19)
            $0.width.equalTo(38)
            $0.height.equalTo(24)
        }
        
        separatorLine.snp.makeConstraints {
            $0.top.equalTo(pushSettingLabel.snp.bottom).offset(26)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    private func setTimeLayout() {
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(separatorLine.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(20)
        }
        
        timeContainerView.addSubview(timeSettingLabel)
        
        timeContainerView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(8)
            $0.leading.equalTo(timeLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(48)
        }
        
        timeSettingLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
        }
    }
    
    private func setDayLayout() {
        dayLabel.snp.makeConstraints {
            $0.top.equalTo(timeContainerView.snp.bottom).offset(40)
            $0.leading.equalTo(timeLabel.snp.leading)
        }
        
        dayStackView.snp.makeConstraints {
            $0.top.equalTo(dayLabel.snp.bottom).offset(9)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(40)
        }
        
        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(56)
        }
    }
    
}
