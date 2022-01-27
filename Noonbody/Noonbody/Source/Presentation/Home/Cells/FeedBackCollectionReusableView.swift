//
//  FeedBackCollectionReusableView.swift
//  Noonbody
//
//  Created by kong on 2022/01/26.
//

import UIKit

import Then
import SnapKit

protocol footerDelegate: AnyObject {
    func feedBackButtonDidTap()
}

class FeedBackCollectionReusableView: UICollectionReusableView {
    
    let feedBackButton = UIButton().then {
        $0.backgroundColor = Asset.Color.gray10.color
        $0.makeRounded(radius: 4)
        $0.addTarget(self, action: #selector(feedBackButtonDidTap), for: .touchUpInside)
    }
    
    private let postEmojiLabel = UILabel().then {
        $0.font = .nbFont(type: .header2)
        $0.text = "📮"
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .nbFont(type: .body3)
        $0.textColor = Asset.Color.gray90.color
        $0.text = "눈바디 사용경험을 알려주세요"
    }
    
    private let arrowImage = UIImageView().then {
        $0.image = Asset.Image.next.image
    }
    
    weak var delegate: footerDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraint()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViewHierarchy() {
        addSubviews(feedBackButton)
        feedBackButton.addSubviews(postEmojiLabel, titleLabel, arrowImage)
    }
    
    func setupConstraint() {
        feedBackButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        postEmojiLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(15)
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(postEmojiLabel.snp.trailing).offset(8)
        }

        arrowImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(15)
        }
    }
    
    @objc
    private func feedBackButtonDidTap() {
        delegate?.feedBackButtonDidTap()
    }
}
