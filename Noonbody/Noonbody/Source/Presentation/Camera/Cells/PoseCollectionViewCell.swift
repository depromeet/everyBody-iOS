//
//  PoseCollectionViewCell.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/30.
//

import UIKit

import Then
import SnapKit

class PoseCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    private let poseThumnailImageView = UIImageView()
    private let selectedView = SelectedView(style: .basic)
    private let nonePoseImageView = UIImageView().then {
        $0.image = Asset.Image.none.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = Asset.Color.Text.primary.color
    }
    
    // MARK: - Properties
    
    override var isSelected: Bool {
        didSet {
            isSelected ? setSelectedCell() : setUnselectedCell()
        }
    }
    
    // MARK: - Initalizer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setLayout()
        render()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func render() {
        backgroundColor = .white
        makeRounded(radius: 4)
    }
    
    private func setLayout() {
        addSubview(poseThumnailImageView)
        
        poseThumnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setSelectedCell() {
        addSubview(selectedView)
        
        selectedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setUnselectedCell() {
        selectedView.removeFromSuperview()
    }
    
    func setData(image: UIImage) {
        poseThumnailImageView.image = image
    }
    
    func setFirstCell() {
        addSubview(nonePoseImageView)
        
        nonePoseImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
}
