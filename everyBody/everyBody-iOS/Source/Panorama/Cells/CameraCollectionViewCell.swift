//
//  CameraCollectionViewCell.swift
//  everyBody-iOS
//
//  Created by kong on 2021/11/19.
//

import UIKit

import SnapKit

class CameraCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CameraCollectionViewCell"
    
    // MARK: - UIComponenets
    
    var cameraButton = UIButton().then {
        $0.backgroundColor = Asset.Color.keyPurple.color
        $0.setImage(Asset.Image.photoCamera.image, for: .normal)
    }
    
    // MARK: - Properties
    
    var viewModel = PanoramaViewModel()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setConstraints()
    }
    
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
        contentView.addSubview(cameraButton)
    }
    
    func setConstraints() {
        cameraButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func transformToCenter() {

    }
    
    func transformToStandard() {

    }
    
}
