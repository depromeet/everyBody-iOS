//
//  AlbumCollectionViewCell.swift
//  everyBody-iOS
//
//  Created by kong on 2021/11/03.
//

import UIKit

import SnapKit
import Then

class BottomCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UIComponenets
    
    private var panoramaCellImage = UIImageView().then {
        $0.makeRounded(radius: 4)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    private var bottomView = UIView()
    private var tagView = UIView()
    private var tagLabel = UILabel().then {
        $0.textColor = Asset.Color.gray50.color
        $0.textAlignment = .center
        $0.font = .nbFont(ofSize: 10, weight: .bold, type: .pretendard)
    }
    
    // MARK: - Properties

    override var isSelected: Bool {
        didSet {
            isSelected ? transformToCenter() : transformToStandard()
        }
    }
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setConstraints()
        transformToStandard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        transformToStandard()
    }
    
    // MARK: - LifeCycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupViewHierarchy()
    }
    
    // MARK: - Actions
    
    // MARK: - Methods
    
    private func setupViewHierarchy() {
        contentView.addSubviews(panoramaCellImage, bottomView)
        bottomView.addSubviews(tagView, tagLabel)
    }
    
    private func setConstraints() {
        panoramaCellImage.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(contentView.frame.width * (4/3)).priority(999)
        }
        
        bottomView.snp.makeConstraints {
            $0.top.equalTo(panoramaCellImage.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        tagLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        tagView.snp.makeConstraints {
            $0.top.bottom.equalTo(tagLabel).inset(-3)
            $0.leading.trailing.equalTo(tagLabel).inset(-8)
        }
        
    }
    
    func setCell(index: Int, imageURL: String) {
        panoramaCellImage.setImage(with: imageURL)
        tagLabel.text = "\(index+1)"
        tagLabel.sizeToFit()
        
        if index == 0 {
            transformToCenter()
        }
    }
    
    func transformToCenter() {
        tagView.backgroundColor = Asset.Color.keyPurple.color
        tagLabel.textColor = .white
        panoramaCellImage.makeRoundedWithBorder(radius: 4, color: Asset.Color.keyPurple.color.cgColor, borderWith: 2)
        tagView.makeRoundedWithBorder(radius: 10, color: Asset.Color.keyPurple.color.cgColor, borderWith: 2)
    }
    
    func transformToStandard() {
        tagView.backgroundColor = .clear
        tagLabel.textColor = Asset.Color.gray50.color
        panoramaCellImage.makeRoundedWithBorder(radius: 4, color: UIColor.clear.cgColor)
        tagView.makeRoundedWithBorder(radius: 10, color: UIColor.clear.cgColor)
    }
    
}
