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
        backgroundColor = Asset.Color.gray20.color
        setTitleColor(.black, for: .normal)
        titleLabel?.font = .nbFont(type: .body3)
    }
    
    private func setButtonState() {
        if isSelected {
            makeVibrate()
            setTitleColor(.white, for: .normal)
            titleLabel?.font = .nbFont(ofSize: 14, weight: .bold)
            backgroundColor = Asset.Color.keyPurple.color
            imageView?.tintColor = .white
        } else {
            setTitleColor(.black, for: .normal)
            titleLabel?.font = .nbFont(ofSize: 14, weight: .regular)
            backgroundColor = Asset.Color.gray20.color
            imageView?.tintColor = .black
        }
    }
}
