//
//  SelectedView.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/07.
//

import UIKit

class SelectedView: UIView {

    enum Style {
        case fill
        case basic
    }
    
    private var style: Style
    private lazy var checkImage = UIImageView()
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        
        render()
        setupAttribute()
        setupContraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func render() {
        backgroundColor = Asset.Color.Primary.main.color.withAlphaComponent(0.6)
    }
    
    func setupAttribute() {
        switch style {
        case .fill:
            checkImage.image = Asset.Image.checkCircle.image
        case .basic:
            checkImage.image = Asset.Image.check.image
        }
    }
    
    func setupContraint() {
        addSubview(checkImage)
        
        switch style {
        case .fill:
            checkImage.snp.makeConstraints {
                $0.top.trailing.equalToSuperview().inset(8)
            }
        case .basic:
            checkImage.snp.makeConstraints {
                $0.centerX.centerY.equalToSuperview()
            }
        }
    }
}
