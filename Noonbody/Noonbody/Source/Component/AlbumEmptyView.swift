//
//  albumEmptyView.swift
//  Noonbody
//
//  Created by kong on 2021/12/17.
//

import UIKit

import Then
import SnapKit

class AlbumEmptyView: UIView {
    
    enum ViewType {
        case album
        case picture
    }
    
    private lazy var emptyDescription = UILabel().then {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .nbFont(type: .body2)
        $0.textColor = Asset.Color.gray50.color
    }
    
    var button = UIButton().then {
        $0.backgroundColor = Asset.Color.keyPurple.color
        $0.makeRounded(radius: 28)
    }
    
    var viewType: ViewType?
    
    init(type: ViewType) {
        self.viewType = type
        super.init(frame: .zero)
        setLayout()
        setText(type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        addSubviews(emptyDescription, button)
        
        emptyDescription.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        button.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.width.equalTo(121)
            $0.centerX.bottom.equalToSuperview()
        }
    }
    
    private func setText(type: ViewType) {
        switch type {
        case .album:
            emptyDescription.text = "앨범이 없습니다.\n지금 앨범을 만들어 기록해보세요."
            button.setTitle("앨범 생성", for: .normal)
        case .picture:
            emptyDescription.text = "저장된 사진이 없습니다.\n지금 사진을 찍어 기록해보세요."
            button.setTitle("사진 촬영", for: .normal)
        }
    }
}
