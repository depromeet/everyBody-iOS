//
//  NBPrimaryButton.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/22.
//

import UIKit

class NBPrimaryButton: UIButton {

    override var isEnabled: Bool {
        didSet {
            isEnabled ? setEnableButtonUI() : setDisableButtonUI()
        }
    }
    
    public var rounding: CGFloat = 4 {
        didSet {
            setButtonRound()
        }
    }
    
    public init() {
        super.init(frame: .zero)
        
        setDisableButtonUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setEnableButtonUI() {
        isUserInteractionEnabled = true
        backgroundColor = Asset.Color.Primary.main.color
        setTitleColor(.white, for: .normal)
    }
    
    private func setDisableButtonUI() {
        isUserInteractionEnabled = false
        backgroundColor = Asset.Color.Primary.main.color.withAlphaComponent(0.5)
        setTitleColor(.white.withAlphaComponent(0.5), for: .normal)
    }
    
    private func setButtonRound() {
        makeRounded(radius: rounding)
    }
    
}
