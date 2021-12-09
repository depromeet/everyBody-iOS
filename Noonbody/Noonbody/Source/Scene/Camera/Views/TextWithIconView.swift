//
//  TextWithIconView.swift
//  Noonbody
//
//  Created by 윤예지 on 2021/12/10.
//

import UIKit

import Then
import SnapKit

class TextWithIconView: UIView {

    private var icon = UIImageView()
    private var title = UILabel().then {
        $0.font = .nbFont(type: .caption1)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(icon: UIImage, title: String) {
        self.init()
        self.icon.image = icon
        self.title.text = title
    }

    private func setLayout() {
        addSubviews(icon, title)

        icon.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(32)
        }

        title.snp.makeConstraints {
            $0.top.equalTo(icon.snp.bottom).offset(4)
            $0.centerX.equalTo(icon)
        }
    }
}
