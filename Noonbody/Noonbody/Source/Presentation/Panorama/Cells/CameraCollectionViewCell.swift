//
//  CameraCollectionViewCell.swift
//  everyBody-iOS
//
//  Created by kong on 2021/11/19.
//

import UIKit

import SnapKit

class CameraCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UIComponenets
    
    var cameraImage = UIImageView().then {
        $0.image = Asset.Image.photoCamera.image
    }
    
    // MARK: - Properties
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setConstraints()
        setCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    // MARK: - Actions
    
    // MARK: - Methods
    
    func setupViewHierarchy() {
        contentView.addSubview(cameraImage)
    }
    
    func setConstraints() {
        cameraImage.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func setCell() {
        contentView.backgroundColor = Asset.Color.Primary.main.color
    }
}
