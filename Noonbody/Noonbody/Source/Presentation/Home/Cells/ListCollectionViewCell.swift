//
//  ListCollectionViewCell.swift
//  Noonbody
//
//  Created by 윤예지 on 2021/12/17.
//

import UIKit

import Then
import SnapKit

class ListCollectionViewCell: UICollectionViewCell {

    private let titleLabel = UILabel().then {
        $0.font = .nbFont(type: .header1)
        $0.textColor = .white
    }
    private let descriptionLabel = UILabel().then {
        $0.font = .nbFont(type: .body2)
        $0.textColor = .white
    }
    private let thumbnailImageView = UIImageView().then {
        $0.image = Asset.Image.empty2.image
        $0.contentMode = .scaleAspectFill
        $0.makeRounded(radius: 6)
        $0.clipsToBounds = true
    }
    private let gradationImageView = UIImageView().then {
        $0.image = Asset.Image.listGradation.image
        $0.contentMode = .scaleAspectFill
        $0.makeRounded(radius: 6)
        $0.clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupConstraint()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        initCell()
    }
    
    func setupViewHierarchy() {
        addSubviews(thumbnailImageView, gradationImageView, titleLabel, descriptionLabel)
    }
    
    func setupConstraint() {
        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        gradationImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-20)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
    }
    
    func setData(album: Album) {
        titleLabel.text = album.name
        descriptionLabel.text = album.albumDescription
        if UserManager.hideThumbnail {
            thumbnailImageView.image = Asset.Image.privacyThumbnail.image
        } else {
            if let thumbnailURL = album.thumbnailURL {
                thumbnailImageView.image = AlbumManager.loadImageFromDocumentDirectory(from: thumbnailURL)
            } else {
                thumbnailImageView.image = Asset.Image.empty2.image
            }
        }
    }
}
