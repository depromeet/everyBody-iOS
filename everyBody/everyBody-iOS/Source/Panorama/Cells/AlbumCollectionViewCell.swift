//
//  AlbumCollectionViewCell.swift
//  everyBody-iOS
//
//  Created by kong on 2021/11/03.
//

import SnapKit
import UIKit
import Then

class AlbumCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "AlbumCollectionViewCell"
    
    // MARK: - UIComponenets
    
    var panoramaCellImage = UIImageView().then {
        $0.makeRounded(radius: 4)
        $0.contentMode = .scaleAspectFill
    }
    
    var tagView = UIView().then {
        $0.makeRounded(radius: 10)
    }
    var tagLabel = UILabel().then {
        $0.textColor = Asset.Color.gray50.color
        $0.textAlignment = .center
    }
    
    // MARK: - Properties
    
    var viewModel = PanoramaViewModel()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupViewHierarchy()
    }
    
    // MARK: - Actions
    
    // MARK: - Methods
    
    func setupViewHierarchy() {
        contentView.addSubviews(panoramaCellImage,tagView)
        tagView.addSubview(tagLabel)
    }
    
    func setConstraints() {
        panoramaCellImage.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(48 * Constant.Size.screenWidth / 375)
            $0.height.equalTo(64 * Constant.Size.screenHeight / 812)
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
    
    func setCell(index: Int) {
        panoramaCellImage.image = viewModel.phothArray[index]
        tagLabel.text = "\(index+1)"
        tagLabel.sizeToFit()
    }
    
    func transformToCenter() {
        tagView.backgroundColor = Asset.Color.keyPurple.color
        tagLabel.textColor = .white
        panoramaCellImage.makeRoundedWithBorder(radius: tagLabel.frame.height/2, color: Asset.Color.keyPurple.color.cgColor, borderWith: 2)
    }
    
    func transformToStandard() {
        tagView.backgroundColor = .clear
        tagLabel.textColor = Asset.Color.gray50.color
        panoramaCellImage.makeRoundedWithBorder(radius: tagLabel.frame.height/2, color: UIColor.clear.cgColor)
    }
    
}
