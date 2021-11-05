//
//  PoseCollectionViewCell.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/30.
//

import UIKit

class PoseCollectionViewCell: UICollectionViewCell {
    
    private let poseThumnailImageView = UIImageView()
    private let selectedView = UIView().then {
        $0.backgroundColor = Asset.Color.keyPurple.color.withAlphaComponent(0.6)
    }
    override var isSelected: Bool {
        didSet {
            isSelected ? setSelectedCell() : setUnselectedCell()
        }
    }
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         
         setLayout()
         render()
     }
     
     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
     
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
    
    func bind() {
        
    }
    
}
