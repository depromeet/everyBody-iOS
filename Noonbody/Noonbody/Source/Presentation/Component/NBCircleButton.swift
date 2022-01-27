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
    
    private func setInitialState() {
        backgroundColor = .white
        setTitleColor(Asset.Color.gray80.color, for: .normal)
        titleLabel?.font = .nbFont(type: .body3)
        makeRoundedWithBorder(radius: 20, color: Asset.Color.gray40.color.cgColor, borderWith: 1)
    }
    
    private func setSelectedState() {
//        let selectedColor = type
        guard let type = self.type else { return }
        var selectedColor: UIColor
        
        switch type {
        case .day:
            selectedColor = Asset.Color.gray80.color
        case .rate:
            selectedColor = Asset.Color.keyPurple.color
        }
        
        if isSelected {
            backgroundColor = selectedColor
            layer.borderColor = UIColor.clear.cgColor
            setTitleColor(.white, for: .normal)
            titleLabel?.font = .nbFont(type: .body3Semibold)
        } else {
            backgroundColor = .white
            layer.borderColor = Asset.Color.gray40.color.cgColor
            setTitleColor(Asset.Color.gray80.color, for: .normal)
            titleLabel?.font = .nbFont(type: .body3)
        }
    }

}
