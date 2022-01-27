//
//  NotificationViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import UIKit

import RxCocoa
import RxSwift

enum State {
    case selected
    case unselected
}

class NotificationViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private let pushSettingLabel = UILabel().then {
        $0.text = "앱 푸시 알림"
        $0.font = .nbFont(type: .body2)
        $0.textColor = Asset.Color.gray80.color
    }
    
    private lazy var pushSwitch = CustomSwitch(width: 38, height: 24).then {
        $0.descriptionLabel.isHidden = true
        $0.setOffColor(color: Asset.Color.gray30.color)
        $0.delegate = self
    }
    
    private let separatorLine = UIView().then {
        $0.backgroundColor = Asset.Color.gray10.color
    }
    
    private let pushSettingContainerView = UIView()
    
    private let timeLabel = UILabel().then {
        $0.text = "시간"
        $0.font = .nbFont(type: .body3)
        $0.textColor = Asset.Color.gray80.color
    }
    
    private let timeTextField = UITextField().then {
        $0.font = .nbFont(type: .body3)
        $0.textColor = Asset.Color.gray80.color
        $0.isUserInteractionEnabled = false
    }
    
    private let timeContainerView = UIView().then {
        $0.makeRoundedWithBorder(radius: 4,
                                 color: Asset.Color.gray80.color.cgColor,
                                 borderWith: 1)
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
            
            dayButtonObservable.onNext(dayButtonList.map { $0.1 })
        }
    }
    
    private lazy var saveButton = NBPrimaryButton().then {
        $0.setTitle("저장", for: .normal)
        $0.isEnabled = false
        $0.makeRounded(radius: 28)
    }
    
    // MARK: - Properties
    
    private let viewModel = NotificationViewModel(profileUseCase: DefaultProfileUseCase(
                                                  preferenceRepository: DefaultPreferenceRepository()))
    private let dayButtonObservable = PublishSubject<[State]>()
    private let timeText = BehaviorSubject<String>(value: "")
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        createButtons()
        initNavigationBar()
        setupConstraint()
        addTapGesture()
        addLifeCycleObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: notificationSettingsCompletionHandler)
    }
    
    // MARK: - Notification oberserver methods
    
    @objc
    func willEnterForeground() {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: notificationSettingsCompletionHandler)
    }
    
    // MARK: - Methods
    
    private func bind() {
        let input = NotificationViewModel.Input(viewWillAppear: rx.viewWillAppear.map { _ in },
                                                dayList: dayButtonObservable,
                                                time: timeTextField.rx.text.orEmpty.asObservable(),
                                                saveButtonControlEvent: saveButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.dayConfig
            .drive(onNext: { [weak self] data in
                guard let self = self else { return }
                data.enumerated().forEach { index, config in
                    self.dayButtonList[index].0.isSelected = config
                    self.dayButtonList.enumerated().forEach { index, button in
                        if button.0.isSelected {
                            self.dayButtonList[index].1 = .selected
                        }
                    }
                }
            }).disposed(by: disposeBag)
        
        output.timeConfig
            .drive(onNext: { [weak self] date in
                guard let self = self else { return }
                let hour = date[0]
                let minute = date[1]
                self.timeTextField.text = "\(hour):\(minute)"
                self.timeTextField.sendActions(for: .valueChanged)
            }).disposed(by: disposeBag)
        
        output.statusCode
            .drive(onNext: { [weak self] statusCode in
                guard let self = self else { return }
                if statusCode == 200 {
                    self.showToast(type: .alarm)
                }
            }).disposed(by: disposeBag)
        
        timeText
            .bind(to: timeTextField.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func initNavigationBar() {
        navigationController?.initNaviBarWithBackButton()
        title = "알림 설정"
    }
    
    private func createButtons() {
        viewModel.weekday.forEach { day in
            let button = NBDayButton()
            button.setTitle(day, for: .normal)
            button.addTarget(self, action: #selector(self.setAction(sender:)), for: .touchUpInside)
            dayButtonList.append((button, .unselected))
            self.dayStackView.addArrangedSubview(button)
        }
    }
    
    private func addLifeCycleObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
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
    
    // MARK: - Actions
    
    private func addTapGesture() {
        let timeSelectViewGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                                   action: #selector(timeSelectViewDidTap))
        timeContainerView.addGestureRecognizer(timeSelectViewGesture)
    }
    
    @objc
    private func timeSelectViewDidTap() {
        let popUp = PopUpViewController(type: .picker)
        popUp.modalTransitionStyle = .crossDissolve
        popUp.modalPresentationStyle = .overCurrentContext
        popUp.delegate = self
        popUp.initalDate = timeTextField.text?.split(separator: ":").map { Int(String($0))! } ?? []
        popUp.setupInitialPicerView()
        self.present(popUp, animated: true, completion: nil)
    }
    
    @objc
    private func notificationSettingsCompletionHandler(settings: UNNotificationSettings) {
        DispatchQueue.main.async {
            self.pushSwitch.isOn = settings.authorizationStatus == .authorized ? true : false
            self.pushSettingContainerView.isHidden = !self.pushSwitch.isOn
            self.saveButton.isHidden = !self.pushSwitch.isOn
        }
    }
}

extension NotificationViewController: PopUpActionProtocol {
    
    func cancelButtonDidTap(_ button: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func confirmButtonDidTap(_ button: UIButton, textInfo: String) {
        timeTextField.text = textInfo
        timeTextField.sendActions(for: .valueChanged)
        dismiss(animated: true, completion: nil)
    }
    
}

extension NotificationViewController: CustomSwitchDelegate {
    
    func switchButtonStateChanged(isOn: Bool) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
}

// MARK: - Layout

extension NotificationViewController {
    
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
                                             dayStackView,
                                             timeTextField)
        
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
        
        timeContainerView.addSubview(timeTextField)
        
        timeContainerView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(8)
            $0.leading.equalTo(timeLabel.snp.leading)
            $0.trailing.equalToSuperview().inset(21)
            $0.height.equalTo(48)
        }
        
        timeTextField.snp.makeConstraints {
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
