//
//  NBBasicButton.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/05.
//

import UIKit

class NBBasicButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            setButtonState()
        }
    }

    public init() {
        super.init(frame: .zero)
        setInitialState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setInitialState() {
        backgroundColor = .clear
        setTitleColor(Asset.Color.Primary.main.color, for: .normal)
        titleLabel?.font = .nbFont(type: .body2)
    }
    
    private func setButtonState() {
        if isSelected {
            setTitleColor(Asset.Color.Primary.main.color, for: .normal)
            titleLabel?.font = .nbFont(ofSize: 16, weight: .bold)
        } else {
            setTitleColor(Asset.Color.Text.tertirary.color, for: .normal)
            titleLabel?.font = .nbFont(type: .body2)
        }
    }
    
}
