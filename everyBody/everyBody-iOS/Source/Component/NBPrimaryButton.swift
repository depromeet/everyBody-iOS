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
        backgroundColor = Asset.Color.keyPurple.color
        setTitleColor(.white, for: .normal)
    }
    
    private func setDisableButtonUI() {
        backgroundColor = Asset.Color.gray30.color
        setTitleColor(Asset.Color.gray50.color, for: .normal)
    }
    
    private func setButtonRound() {
        makeRounded(radius: rounding)
    }
    
}
