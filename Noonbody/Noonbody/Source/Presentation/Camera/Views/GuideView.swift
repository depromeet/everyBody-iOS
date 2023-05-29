//
//  ToastView.swift
//  Noonbody
//
//  Created by 윤예지 on 2021/10/31.
//

import UIKit

class GuideView: UIView {

    private var infoLabel = UILabel().then {
        $0.textColor = .white
        $0.text = "원하는 포즈를 선택해주세요"
        $0.font = .nbFont(type: .body3)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        render()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func render() {
        backgroundColor = Asset.Color.Primary.main.color.withAlphaComponent(0.8)
    }

    private func setLayout() {
        addSubview(infoLabel)

        infoLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }

}
