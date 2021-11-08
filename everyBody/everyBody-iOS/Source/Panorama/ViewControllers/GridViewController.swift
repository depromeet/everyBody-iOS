//
//  GridViewController.swift
//  everyBody-iOS
//
//  Created by kong on 2021/11/05.
//

import SnapKit
import Then
import UIKit

class GridViewController: UIViewController {
    
    
    // MARK: - UI Components
    
    var gridCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
//        $0.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: AlbumCollectionViewCell.identifier)
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
        $0.allowsMultipleSelection = false
        $0.collectionViewLayout = layout
    }
    
    // MARK: - Properties
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Methods
    
    private func setupViewHierarchy() {
        view.addSubview(gridCollectionView)
    }
    
    private func setupConstraint() {
        
        gridCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        
    }
    
    
    // MARK: - Actions
    
    
}


// MARK: - View Layout

