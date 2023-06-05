//
//  NBCircleButton.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import UIKit

class NBCircleButton: UIButton {
    
    enum Style {
        case day
        case rate
    }

    override var isSelected: Bool {
        didSet {
            setSelectedState()
        }
    }
    
    var type: Style?
    
    public init(type: Style?) {
        self.type = type
        super.init(frame: .zero)
        setInitialState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = isSelected ? UIColor.clear.cgColor : Asset.Color.borderLine.color.cgColor
    }
    
    private func setInitialState() {
        backgroundColor = .clear
        setTitleColor(Asset.Color.Text.primary.color, for: .normal)
        titleLabel?.font = .nbFont(type: .body3)
        makeRoundedWithBorder(radius: 20,
                              color: Asset.Color.borderLine.color.cgColor,
                              borderWith: 1)
    }
    
    private func setSelectedState() {
        guard let type = self.type else { return }
        var selectedColor: UIColor
        
        switch type {
        case .day:
            selectedColor = Asset.Color.Primary.text.color
        case .rate:
            selectedColor = Asset.Color.Primary.main.color
        }
        
        if isSelected {
            backgroundColor = selectedColor
            layer.borderColor = UIColor.clear.cgColor
            setTitleColor(.white, for: .normal)
            titleLabel?.font = .nbFont(type: .body3Semibold)
        } else {
            backgroundColor = .clear
            layer.borderColor = Asset.Color.borderLine.color.cgColor
            setTitleColor(Asset.Color.Text.secondary.color, for: .normal)
            titleLabel?.font = .nbFont(type: .body3)
        }
    }

}
