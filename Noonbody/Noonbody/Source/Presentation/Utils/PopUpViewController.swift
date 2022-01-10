//
//  PopUpViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/17.
//

import UIKit

class PopUpViewController: BaseViewController {
    
    enum Style {
        case delete
        case textField
        case picker
        case oneButton
    }
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.makeRounded(radius: 8)
    }
    
    lazy var titleLabel = UILabel().then {
        $0.font = .nbFont(type: .subtitle)
        $0.textColor = Asset.Color.gray90.color
    }
    
    lazy var descriptionLabel = UILabel().then {
        $0.font = .nbFont(type: .body2)
        $0.textAlignment = .center
        $0.textColor = Asset.Color.gray80.color
        $0.numberOfLines = 0
    }
    
    lazy var textField = NBTextField().then {
        $0.font = .nbFont(type: .body2)
        $0.setPlaceHoder(placehoder: "폴더명을 입력해주세요")
    }
    
    private lazy var datePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.preferredDatePickerStyle = .wheels
    }
    
    private let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.titleLabel?.font = .nbFont(type: .body2)
        $0.setTitleColor(Asset.Color.gray80.color, for: .normal)
        $0.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
    }
    
    let confirmButton = UIButton().then {
        $0.setTitle("완료", for: .normal)
        $0.titleLabel?.font = .nbFont(type: .body2SemiBold)
        $0.setTitleColor(Asset.Color.keyPurple.color, for: .normal)
        $0.addTarget(self, action: #selector(confirmButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - Properties
    
    var type: Style?
    weak var delegate: PopUpActionProtocol?
    var initalDate: [Int] = []
    
    // MARK: - Initalizer
    
    convenience init() {
        self.init(type: nil)
    }
    
    init(type: Style?) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        
        hideKeyboard()
        render()
        setViewHierachy()
        setupConstraint()
        setupInitialPicerView()
    }
    
    // MARK: - Methods
    
    override func render() {
        view.backgroundColor = Asset.Color.gray90.color.withAlphaComponent(0.3)
    }
    
    private func setViewHierachy() {
        view.addSubview(containerView)
        containerView.addSubviews(titleLabel, descriptionLabel, textField, cancelButton, confirmButton)
    }
    
    private func setupConstraint() {
        guard let type = self.type else { return }
        
        containerView.snp.makeConstraints {
            $0.width.equalTo(320)
            $0.height.equalTo(220)
            $0.centerX.centerY.equalToSuperview()
        }
        
        switch type {
        case .delete, .textField, .picker:
            cancelButton.snp.makeConstraints {
                $0.width.equalTo(160)
                $0.height.equalTo(56)
                $0.leading.bottom.equalToSuperview()
            }
            
            confirmButton.snp.makeConstraints {
                $0.width.equalTo(160)
                $0.height.equalTo(56)
                $0.trailing.bottom.equalToSuperview()
            }
            
            if type == .picker {
                containerView.addSubview(datePicker)
                datePicker.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(37)
                    $0.centerX.equalToSuperview()
                    $0.height.equalTo(120)
                }
            } else {
                titleLabel.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(32)
                    $0.centerX.equalToSuperview()
                }
                
                if type == .delete {
                    descriptionLabel.snp.makeConstraints {
                        $0.top.equalTo(titleLabel.snp.bottom).offset(30)
                        $0.centerX.equalToSuperview()
                    }
                } else if type == .textField {
                    textField.snp.makeConstraints {
                        $0.top.equalTo(titleLabel.snp.bottom).offset(24)
                        $0.centerX.equalToSuperview()
                        $0.width.equalTo(280)
                        $0.height.equalTo(48)
                    }
                }
            }
        case .oneButton:
            cancelButton.snp.makeConstraints {
                $0.height.equalTo(56)
                $0.leading.bottom.trailing.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(32)
                $0.centerX.equalToSuperview()
            }
            
            descriptionLabel.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(30)
                $0.centerX.equalToSuperview()
                $0.leading.trailing.equalToSuperview().inset(20)
            }

            return
        }
    }
    
    // MARK: - Actions
    
    @objc
    func cancelButtonDidTap() {
        delegate?.cancelButtonDidTap(cancelButton)
    }
    
    @objc
    func confirmButtonDidTap() {
        guard let type = self.type else { return }
        
        switch type {
        case .delete:
            delegate?.confirmButtonDidTap(confirmButton)
        case .textField:
            if let text = textField.text, !text.isEmpty {
                delegate?.confirmButtonDidTap(confirmButton, textInfo: text)
            }
        case .picker:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            delegate?.confirmButtonDidTap(confirmButton, textInfo: dateFormatter.string(from: datePicker.date))
        case .oneButton:
            return
        }
    }
    
    private func setupInitialPicerView() {
        if type == .picker {
            let dateString: String = "\(initalDate[0]):\(initalDate[1])"
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = "HH:mm"
            dateFormatter.timeZone = NSTimeZone(name: "KST") as TimeZone?
            
            let date: Date = dateFormatter.date(from: dateString)!
            datePicker.date = date
        }
    }
    
    func setCancelButtonTitle(text: String) {
        cancelButton.setTitle(text, for: .normal)
    }
}
