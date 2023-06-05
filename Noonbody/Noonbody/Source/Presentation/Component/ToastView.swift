//
//  ToastView.swift
//  Noonbody
//
//  Created by 윤예지 on 2021/12/10.
//

import UIKit

import Then
import SnapKit

enum ToastType: String {
    case album = "앨범이 추가되었습니다."
    case alarm = "알림 설정이 완료되었습니다."
    case delete = "사진이 삭제되었습니다."
    case save = "성공적으로 저장되었습니다."
    case send = "소중한 피드백 감사합니다 💪👀"
}

class ToastView: UIView {
    
    private let checkImageView = UIImageView().then {
        $0.image = Asset.Image.checkCircle.image
    }
    private let textLabel = UILabel().then {
        $0.textColor = .white
        $0.font = .nbFont(type: .body3)
    }
    
    init(type: ToastType) {
        super.init(frame: .zero)
        
        render()
        setLayout()
        setText(with: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func render() {
        makeRounded(radius: 10)
        backgroundColor = Asset.Color.Primary.main.color
    }

    private func setLayout() {
        addSubviews(checkImageView, textLabel)
        
        checkImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(16)
            $0.width.height.equalTo(16)
        }
        
        textLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(checkImageView.snp.trailing).offset(4)
        }
    }
    
    private func setText(with stringType: ToastType) {
        textLabel.text = stringType.rawValue
    }
    
}
