//
//  VideoEditViewController.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/11.
//

import UIKit

class VideoEditViewController: BaseViewController {
    
    enum SectionKind: Int {
        case previewList
    }
    
    // MARK: - Properties
    
    private var firstLaunch: Bool = true
    private var isSelectedEvent: Bool = false
    private var imageList: [ImageInfo] = []
    private var backingList: [(ImageInfo, Int)] = []
    private let cellWidth: CGFloat = 52
    private let cellHeight: CGFloat = 68
    
    // MARK: - UI Components
    
    private var dataSource: UICollectionViewDiffableDataSource<SectionKind, ImageInfo>! = nil
    private var collectionView: UICollectionView!
    private var centerCell: PreviewCollectionViewCell?
    private var imageView = UIImageView()
    private var totalImageCountLabel = UILabel().then {
        $0.font = .nbFont(type: .caption1Semibold)
        $0.textColor = .white
    }
    private let ofLabel = UILabel().then {
        $0.font = .nbFont(type: .caption1)
        $0.text = "중"
        $0.textColor = .white
    }
    private var selectedIndexLabel = UILabel().then {
        $0.font = .nbFont(type: .caption1Semibold)
        $0.text = "1번"
        $0.textColor = .white
    }
    private let restoreButton = UIButton().then {
        $0.setImage(Asset.Image.shareWhite.image, for: .normal)
        $0.addTarget(self, action: #selector(backingButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - Initializer
    
    init(albumData: [(String, String)], title: String) {
        self.imageList = albumData.map { ImageInfo(imageKey: $0.0, imageURL: $0.1) }
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCollectionView()
        initNavigationBar()
        createDataSource()
        setupConstraint()
        selectFirstCell()
        updateCountLabel()
        view.backgroundColor = .black
    }
    
    // MARK: - Methods
    
    private func initNavigationBar() {
        navigationController?.initNavigationBar(navigationItem: self.navigationItem,
                                                rightButtonImages: [Asset.Image.shareWhite.image],
                                                rightActions: [#selector(saveButtonDidTap)],
                                                tintColor: .white)
    }
    
    private func initCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.delegate = self
    }
    
    private func updateCountLabel() {
        totalImageCountLabel.text = "\(imageList.count)장"
    }
    
    private func updateIndexLabel(row: Int) {
        selectedIndexLabel.text = "\(row + 1)번"
    }
    
    private func selectFirstCell() {
        centerCell = self.collectionView.cellForItem(at: [0, 0]) as? PreviewCollectionViewCell
        if centerCell != nil {
            self.firstLaunch.toggle()
        }
        centerCell?.setSelectedUI()
        imageView.setImage(with: imageList[0].imageURL)
    }
    
    private func createDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<PreviewCollectionViewCell, ImageInfo> { cell, _, image in
            cell.setImage(named: image.imageURL)
            cell.identifiter = image
            cell.delegate = self
            if self.firstLaunch {
                self.selectFirstCell()
            }
        }
        
        dataSource = UICollectionViewDiffableDataSource<SectionKind, ImageInfo>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                return collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: item
                )
            }
        )
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, ImageInfo>()
        snapshot.appendSections([.previewList])
        snapshot.appendItems(imageList)
        dataSource.apply(snapshot)
    }
    
    @objc
    private func saveButtonDidTap() {
        // TO DO: 동영상 저장 서버 연결
    }
    
    @objc
    private func backingButtonDidTap() {
        guard let deleteItem = backingList.popLast() else { return }
        var backingStore = imageList
        backingStore.insert(deleteItem.0, at: deleteItem.1)
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, ImageInfo>()
        snapshot.appendSections([.previewList])
        snapshot.appendItems(backingStore)
        dataSource.apply(snapshot)
        
        imageList = backingStore
        moveCellToCenter()
        updateCountLabel()
    }
}

extension VideoEditViewController: DeleteButtonDelegate {
    
    func deleteButtonDidTap(identifier: ImageInfo) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([identifier])
        dataSource.apply(snapshot)
        
        let index = imageList.firstIndex(where: { item in item.imageKey == identifier.imageKey }) ?? 0
        backingList.append((imageList[index], index))
        imageList.remove(at: index)
        
        updateCountLabel()
        if index == imageList.count {
            updateIndexLabel(row: index - 1)
        }
        
        moveCellToCenter()
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension VideoEditViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isSelectedEvent = true
        guard let cell = collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell else { return }
        centerCell = cell
        collectionView.setContentOffset(CGPoint(x: cell.frame.minX - (collectionView.frame.width / 2 - cellWidth / 2),
                                                y: 0.0),
                                        animated: true)
        imageView.setImage(with: self.imageList[indexPath.row].imageURL)
        updateIndexLabel(row: indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isSelectedEvent { return }
        
        let centerPoint = CGPoint(x: collectionView.contentOffset.x + collectionView.frame.size.width / 2, y: 0.0)
        
        if let indexPath = collectionView.indexPathForItem(at: centerPoint), centerCell == nil {
            self.centerCell = self.collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell
            self.centerCell?.setSelectedUI()
            imageView.setImage(with: imageList[indexPath.row].imageURL)
            updateIndexLabel(row: indexPath.row)
        }
        
        if let cell = centerCell {
            let offsetX = centerPoint.x - cell.center.x
            if offsetX < -cell.frame.width / 2 || offsetX > cell.frame.width / 2 {
                cell.setUnselectedUI()
                self.centerCell = nil
            }
        }
    }
    
    private func moveCellToCenter() {
        let centerPoint =  CGPoint(x: collectionView.contentOffset.x + collectionView.frame.size.width / 2, y: 0.0)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.imageView.setImage(with: imageList[indexPath.row].imageURL)
            self.centerCell = self.collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell
            self.centerCell?.setSelectedUI()
            updateIndexLabel(row: indexPath.row)
        }
        
        setUnselectedCellUI()
    }
    
    private func setUnselectedCellUI() {
        let centerPoint =  CGPoint(x: collectionView.contentOffset.x + collectionView.frame.size.width / 2, y: 0.0)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            for row in 0..<imageList.count where row != indexPath.row {
                let cell = self.collectionView.cellForItem(at: [0, row]) as? PreviewCollectionViewCell
                cell?.setUnselectedUI()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        moveCellToCenter()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        moveCellToCenter()
        isSelectedEvent.toggle()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            moveCellToCenter()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = collectionView.frame.width / 2 - cellWidth / 2
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth / Constant.Size.figmaWidth * Constant.Size.screenWidth,
                      height: collectionView.frame.height)
    }

}

// MARK: - Layout

extension VideoEditViewController {
    
    private func setupConstraint() {
        view.addSubviews(imageView, collectionView, totalImageCountLabel,
                         ofLabel, selectedIndexLabel, restoreButton)
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constant.Size.screenWidth * (4.0/3.0))
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(UIDevice.current.hasNotch ? 28 : 5)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(UIDevice.current.hasNotch ? 68 / Constant.Size.figmaHeight * Constant.Size.screenHeight : 40)
        }
        
        ofLabel.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
        }
        
        totalImageCountLabel.snp.makeConstraints {
            $0.top.equalTo(ofLabel.snp.top)
            $0.trailing.equalTo(ofLabel.snp.leading).offset(-4)
        }
        
        selectedIndexLabel.snp.makeConstraints {
            $0.top.equalTo(ofLabel.snp.top)
            $0.leading.equalTo(ofLabel.snp.trailing).offset(4)
        }
        
        restoreButton.snp.makeConstraints {
            $0.top.equalTo(ofLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(10)
        }
    }
    
}

struct ImageInfo: Hashable {
    let imageKey: String
    let imageURL: String
}
