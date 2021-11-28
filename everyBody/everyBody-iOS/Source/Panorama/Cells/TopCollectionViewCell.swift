//
//  GridCollectionViewCell.swift
//  everyBody-iOS
//
//  Created by kong on 2021/11/10.
//

import UIKit

import SnapKit
import Then

class TopCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UIComponenets
    
    var panoramaImage = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let selectedView = SelectedView(style: .fill)
    
    // MARK: - Properties
    
    var viewModel = PanoramaViewModel()
    
    override var isSelected: Bool {
        didSet {
            isSelected ? setSelectedCell() : setUnselectedCell()
        }
    }
    
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
        setConstraints()
    }
    
    // MARK: - Actions
    
    // MARK: - Methods
    
    func setupViewHierarchy() {
        contentView.addSubview(panoramaImage)
    }
    
    func setConstraints() {
        panoramaImage.snp.makeConstraints {
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
    
    func selectedViewIsHidden(editMode: Bool) {
        selectedView.isHidden = !editMode
    }
    
    func setPhotoCell(index: Int) {
        panoramaImage.image = viewModel.phothArray[index]
    }
    
}
