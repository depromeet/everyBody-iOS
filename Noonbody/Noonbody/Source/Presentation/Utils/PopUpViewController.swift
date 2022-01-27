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
        case download
    }
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.makeRounded(radius: 8)
    }
    
    lazy var titleLabel = UILabel().then {
        $0.font = .nbFont(type: .body1Bold)
        $0.textColor = Asset.Color.gray90.color
    }
    
    let descriptionLabel = UILabel().then {
        $0.font = .nbFont(type: .body3)
        $0.textAlignment = .center
        $0.textColor = Asset.Color.gray90.color
        $0.numberOfLines = 2
    }
    
    lazy var textField = NBTextField().then {
        $0.font = .nbFont(type: .body2)
        $0.setPlaceHoder(placehoder: "앨범명을 입력해주세요")
    }
    
    private lazy var datePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.preferredDatePickerStyle = .wheels
    }
    
    let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.titleLabel?.font = .nbFont(type: .body1)
        $0.setTitleColor(Asset.Color.gray90.color, for: .normal)
        $0.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
    }
    
    let confirmButton = UIButton().then {
        $0.setTitle("완료", for: .normal)
        $0.titleLabel?.font = .nbFont(type: .body1Bold)
        $0.setTitleColor(Asset.Color.keyPurple.color, for: .normal)
        $0.setTitleColor(Asset.Color.gray40.color, for: .disabled)
        $0.addTarget(self, action: #selector(confirmButtonDidTap), for: .touchUpInside)
    }
    
    lazy var downloadedPercentView = CircleProgressView()
    
    // MARK: - Properties
    
    var type: Style?
    weak var delegate: PopUpActionProtocol?
    var initalDate: [Int] = []
    
    // MARK: - Initalizer
    
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
        setLineHeight()
    }
    
    // MARK: - Methods
    
    override func render() {
        view.backgroundColor = Asset.Color.gray90.color.withAlphaComponent(0.3)
    }
    
    private func setViewHierachy() {
        view.addSubview(containerView)
    }
    
    private func setupConstraint() {
        guard let type = self.type else { return }
        
        containerView.snp.makeConstraints {
            $0.width.equalTo(320)
            $0.height.equalTo(220)
            $0.center.equalToSuperview()
        }
        
        switch type {
        case .delete, .textField, .picker:
            setTwoButtonUI()
        case .oneButton:
            setOneButtonUI()
        case .download:
            setDownloadUI()
        }
    }
    
    func setTwoButtonUI() {
        removeAllSubviews()
        containerView.addSubviews(cancelButton, confirmButton)
        
        cancelButton.snp.makeConstraints {
            $0.width.equalTo(160)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview().inset(28)
        }
        
        confirmButton.snp.makeConstraints {
            $0.width.equalTo(160)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(28)
        }
        
        if type == .picker {
            containerView.addSubview(datePicker)
            
            datePicker.snp.makeConstraints {
                $0.top.equalToSuperview().offset(30)
                $0.centerX.equalToSuperview()
                $0.height.equalTo(120)
            }
        } else {
            containerView.addSubview(titleLabel)
            
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(36)
                $0.centerX.equalToSuperview()
            }
            
            if type == .delete {
                containerView.addSubview(descriptionLabel)
                
                descriptionLabel.snp.makeConstraints {
                    $0.center.equalToSuperview()
                }
            } else if type == .textField {
                containerView.addSubview(textField)
                
                textField.snp.makeConstraints {
                    $0.top.equalTo(titleLabel.snp.bottom).offset(24)
                    $0.centerX.equalToSuperview()
                    $0.width.equalTo(280)
                    $0.height.equalTo(48)
                }
            }
        }
    }
    
    func setOneButtonUI() {
        removeAllSubviews()
        containerView.addSubviews(cancelButton, titleLabel, descriptionLabel)
        
        cancelButton.snp.makeConstraints {
            $0.width.equalTo(160)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(28)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(36)
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    func setDownloadUI() {
        removeAllSubviews()
        containerView.addSubviews(titleLabel, downloadedPercentView, descriptionLabel, cancelButton)
        
        containerView.snp.updateConstraints {
            $0.width.equalTo(320)
            $0.height.equalTo(283)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(36)
            $0.centerX.equalToSuperview()
        }
        
        downloadedPercentView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(downloadedPercentView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
    
    func setShareButton() {
        containerView.addSubview(confirmButton)
        
        cancelButton.snp.remakeConstraints {
            $0.width.equalTo(160)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview().inset(28)
        }
        
        confirmButton.snp.makeConstraints {
            $0.width.equalTo(160)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(28)
        }
        
        cancelButton.setTitle("확인", for: .normal)
        confirmButton.setTitle("공유하기", for: .normal)
    }
    
    private func removeAllSubviews() {
        [titleLabel, descriptionLabel, textField, cancelButton, confirmButton, downloadedPercentView]
            .forEach { view in
                view.removeFromSuperview()
            }
    }
    
    // MARK: - Actions
    
    @objc
    func cancelButtonDidTap() {
        delegate?.cancelButtonDidTap(cancelButton)
        downloadedPercentView.removeCompletedView()
    }
    
    @objc
    func confirmButtonDidTap() {
        guard let type = self.type else { return }
        
        switch type {
        case .delete, .download:
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
    
    func setupInitialPicerView() {
        if type == .picker && !initalDate.isEmpty {
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
    
    func setDeleteButton() {
        confirmButton.setTitle("삭제", for: .normal)
        confirmButton.setTitleColor(Asset.Color.red.color, for: .normal)
    }
    
    func setLineHeight() {
        descriptionLabel.setLineHeight(20)
    }
}
