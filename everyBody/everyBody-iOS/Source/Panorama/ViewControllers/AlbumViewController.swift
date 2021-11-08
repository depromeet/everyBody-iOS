//
//  AlbumViewController.swift
//  everyBody-iOS
//
//  Created by kong on 2021/11/05.
//

import SnapKit
import Then
import UIKit
import RxSwift

class AlbumViewController: UIViewController {
    
    // MARK: - UI Components

    var panoramaImage = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    var albumCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        $0.bounces = false
        $0.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: AlbumCollectionViewCell.identifier)
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
        $0.allowsMultipleSelection = false
        $0.collectionViewLayout = layout
    
        $0.cellForItem(at: IndexPath(row: 0, section: 0))?.isSelected = true
    }
    
    // MARK: - Properties
    
    var tagSelectedIdx = IndexPath(row: 0, section: 0)
    var centerCell: AlbumCollectionViewCell?
    var viewModel = PanoramaViewModel()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        setupViewHierarchy()
        setupConstraint()
        setView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initCollectionView()
    }
    
    // MARK: - Methods
    
    private func initNavigationBar() {
        self.navigationController?.initWithRightBarTwoButtons(navigationItem: self.navigationItem, rightButtonImage: [UIImage(named: "Create")!, UIImage(named: "Share")!], action: [#selector(tapEditButton), #selector(tapSaveButton)])
        
        //나중에 뷰모델에서 가져올 것
        self.title = "Album Title"
    }

    // MARK: - Actions
    @objc
    private func tapEditButton() {
        
    }
    
    @objc
    private func tapSaveButton() {
        
    }
    
}

// MARK: - View Layout


extension AlbumViewController {
    
    private func setView() {
        albumCollectionView.dataSource = self
        albumCollectionView.delegate = self
    }
    
    private func initCollectionView() {
        centerCell = albumCollectionView.cellForItem(at: IndexPath(row: 0, section: 0)) as? AlbumCollectionViewCell
        centerCell?.transformToCenter()
        panoramaImage.image = viewModel.phothArray[0]
    }
    
    private func setupViewHierarchy() {
        view.addSubviews(panoramaImage,albumCollectionView)
    }
    
    private func setupConstraint() {
        panoramaImage.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constant.Size.screenWidth * (4.0 / 3.0))
        }
        
        albumCollectionView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(panoramaImage.snp.bottom)
            $0.height.equalTo(88 * Constant.Size.screenHeight / 812)
        }
    }
    
}

extension AlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 48 * Constant.Size.screenWidth / 375, height: albumCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = (albumCollectionView.frame.width - 48) / 2
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let centerX = albumCollectionView.frame.size.width / 2 + scrollView.contentOffset.x
        let centerY = albumCollectionView.frame.size.height / 2 + scrollView.contentOffset.y
        let centerPoint = CGPoint(x: centerX, y: centerY)

        if let indexPath = self.albumCollectionView.indexPathForItem(at: centerPoint), self.centerCell == nil {
            self.centerCell = self.albumCollectionView.cellForItem(at: indexPath) as? AlbumCollectionViewCell
            self.centerCell?.transformToCenter()
            panoramaImage.image = viewModel.phothArray[indexPath.row]
            tagSelectedIdx = indexPath
        } else if self.centerCell == nil {
            //셀 중간에 걸렸을 때 처리
        }

        if let cell = centerCell {
            let offsetX = centerPoint.x - cell.center.x
            if offsetX < -cell.frame.width/2 || offsetX > cell.frame.width/2 {
                cell.transformToStandard()
                self.centerCell = nil
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        albumCollectionView.scrollToItem(at: tagSelectedIdx, at: .centeredHorizontally, animated: true)
    }

}

extension AlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.phothArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCollectionViewCell.identifier, for: indexPath) as? AlbumCollectionViewCell else { return UICollectionViewCell() }
        cell.setCell(index: indexPath.row)
        return cell
    }
}
