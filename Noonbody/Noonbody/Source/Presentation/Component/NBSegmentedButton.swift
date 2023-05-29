//
//  NBSegmentedButton.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/04.
//

import UIKit

class NBSegmentedButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            setButtonState()
        }
    }
    
    public init() {
        super.init(frame: .zero)
        setInitalState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setInitalState() {
        backgroundColor = Asset.Color.Background.neutral.color
        setTitleColor(Asset.Color.Text.primary.color, for: .normal)
        titleLabel?.font = .nbFont(type: .body3)
    }
    
    private func setButtonState() {
        if isSelected {
            makeVibrate()
            setTitleColor(.white, for: .normal)
            titleLabel?.font = .nbFont(ofSize: 14, weight: .bold)
            backgroundColor = Asset.Color.Primary.main.color
            imageView?.tintColor = .white
        } else {
            setTitleColor(Asset.Color.Text.primary.color, for: .normal)
            titleLabel?.font = .nbFont(ofSize: 14, weight: .regular)
            backgroundColor = Asset.Color.Background.neutral.color
            imageView?.tintColor = Asset.Color.Text.primary.color
        }
    }
}
