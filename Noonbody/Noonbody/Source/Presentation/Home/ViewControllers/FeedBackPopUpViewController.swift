//
//  FeedBackPopUpViewController.swift
//  Noonbody
//
//  Created by kong on 2022/01/26.
//

import UIKit

class FeedBackPopUpViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.makeRounded(radius: 8)
    }
    
    private let postEmojiLabel = UILabel().then {
        $0.font = .nbFont(ofSize: 48)
        $0.text = "📮"
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .nbFont(type: .body1Bold)
        $0.textColor = Asset.Color.gray90.color
        $0.text = "솔직한 의견을 들려 주세요!"
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = .nbFont(type: .body3)
        $0.textAlignment = .center
        $0.textColor = Asset.Color.gray90.color
        $0.numberOfLines = 2
        $0.text = "의견을 보내주시면 서비스 개선에 반영할게요."
    }
    
    lazy var textField = UITextView().then {
        $0.font = .nbFont(type: .body3)
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        $0.makeRoundedWithBorder(radius: 4, color: Asset.Color.gray90.color.cgColor)
    }
    
    private let subDescriptionLabel = UILabel().then {
        $0.font = .nbFont(type: .caption1)
        $0.textAlignment = .left
        $0.textColor = Asset.Color.gray70.color
        $0.text = "얼마나 만족하시나요?"
    }
    
    private let rateStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 20
    }
    
    private let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.titleLabel?.font = .nbFont(type: .body1)
        $0.setTitleColor(Asset.Color.gray90.color, for: .normal)
        $0.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
    }
    
    private let confirmButton = UIButton().then {
        $0.setTitle("피드백 보내기", for: .normal)
        $0.titleLabel?.font = .nbFont(type: .body1Bold)
        $0.setTitleColor(Asset.Color.keyPurple.color, for: .normal)
        $0.setTitleColor(Asset.Color.gray40.color, for: .disabled)
        $0.addTarget(self, action: #selector(confirmButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - Properties
    
    weak var delegate: PopUpActionProtocol?
    var rateButtonList: [(UIButton, State)] = []
    var starRate = 0
    
    // MARK: - Initalizer
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        render()
        setViewHierachy()
        setupConstraint()
    }
    
    // MARK: - Methods
    
    override func render() {
        view.backgroundColor = Asset.Color.gray90.color.withAlphaComponent(0.3)
    }
    
    private func setViewHierachy() {
        view.addSubview(containerView)
        containerView.addSubviews(postEmojiLabel, titleLabel, descriptionLabel, textField, subDescriptionLabel, rateStackView, cancelButton, confirmButton)
        
        for index in 1...5 {
            let button = NBCircleButton(type: .rate)
            button.setTitle("\(index)", for: .normal)
            button.addTarget(self, action: #selector(self.setAction(sender:)), for: .touchUpInside)
            rateButtonList.append((button, .unselected))
            self.rateStackView.addArrangedSubview(button)
        }
    }
    
    private func setupConstraint() {
        containerView.snp.makeConstraints {
            $0.width.equalTo(320)
            $0.height.equalTo(428)
            $0.center.equalToSuperview()
        }
        
        postEmojiLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(postEmojiLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            $0.height.equalTo(102)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        subDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(16)
            $0.leading.equalTo(rateStackView.snp.leading)
        }
        
        rateStackView.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(subDescriptionLabel.snp.bottom).offset(8)
        }
        
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
    }
    
    // MARK: - Actions
    
    @objc
    private func setAction(sender: UIButton) {
        guard let ratingScore = Int(sender.titleLabel?.text ?? "0") else { return }
        if sender.isSelected, ratingScore < 5 {
            for index in ratingScore...4 {
                rateButtonList[index].0.isSelected = false
            }
        } else {
            for index in 0...ratingScore - 1 {
                rateButtonList[index].0.isSelected = true
            }
        }
        starRate = ratingScore
    }
    
    @objc
    func cancelButtonDidTap() {
        delegate?.cancelButtonDidTap(cancelButton)
    }
    
    @objc
    func confirmButtonDidTap() {
        delegate?.confirmButtonDidTap(confirmButton)
    }
}
