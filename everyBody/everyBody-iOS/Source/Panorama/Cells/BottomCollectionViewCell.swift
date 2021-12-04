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
    
    var panoramaCellImage = UIImageView().then {
        $0.makeRounded(radius: 4)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    var tagView = UIView()
    var tagLabel = UILabel().then {
        $0.textColor = Asset.Color.gray50.color
        $0.textAlignment = .center
    }
    
    // MARK: - Properties
    
    var index = 0
    var viewModel = PanoramaViewModel()
    
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
//        transformToStandard()
    }
    
    // MARK: - Actions
    
    // MARK: - Methods
    
    private func setupViewHierarchy() {
        contentView.addSubviews(panoramaCellImage, tagView)
        tagView.addSubview(tagLabel)
    }
    
    private func setConstraints() {
        panoramaCellImage.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(contentView.frame.width * (4/3) )
        }
        
        tagView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.top.equalTo(panoramaCellImage.snp.bottom).offset(4)
        }
        
        tagLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.top.bottom.equalToSuperview().inset(3)
        }
    }
    
    func setCell(index: Int, imageURL: String) {
        panoramaCellImage.setImage(with: imageURL)
        tagLabel.text = "\(index+1)"
        tagLabel.sizeToFit()
    }
    
    func transformToCenter() {
        tagView.backgroundColor = Asset.Color.keyPurple.color
        tagLabel.textColor = .white
        panoramaCellImage.makeRoundedWithBorder(radius: 4, color: Asset.Color.keyPurple.color.cgColor, borderWith: 2)
        tagView.makeRoundedWithBorder(radius: tagView.frame.height/2, color: Asset.Color.keyPurple.color.cgColor, borderWith: 2)
    }
    
    func transformToStandard() {
        tagView.backgroundColor = .clear
        tagLabel.textColor = Asset.Color.gray50.color
        panoramaCellImage.makeRoundedWithBorder(radius: 4, color: UIColor.clear.cgColor)
        tagView.makeRoundedWithBorder(radius: tagView.frame.height/2, color: UIColor.clear.cgColor)
    }
    
}
