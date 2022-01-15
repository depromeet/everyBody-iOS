//
//  VideoEditViewController.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/11.
//

import UIKit

import RxCocoa
import RxSwift

class VideoEditViewController: BaseViewController {
    
    enum SectionKind: Int {
        case previewList
    }
    
    // MARK: - Properties
    
    private var firstLaunch: Bool = true
    private var isSelectedEvent: Bool = false
    private let cellWidth: CGFloat = 52
    private let cellHeight: CGFloat = 68
    private var viewModel: VideoViewModel
    
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
    private let backingButton = UIButton().then {
        $0.setImage(Asset.Image.shareWhite.image, for: .normal)
    }
    
    // MARK: - Initializer
    
    init(albumData: [(String, String)], title: String) {
        viewModel = VideoViewModel(imageList: albumData.map { ImageInfo(imageKey: $0.0,
                                                                             imageURL: $0.1) })
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
        setInitialSelectedCell()
        updateCountLabel()
        bind()
        view.backgroundColor = .black
    }
    
    // MARK: - Methods
    
    private func bind() {
        let input = VideoViewModel.Input(backingButtonControlEvent: backingButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.restoredImageList
            .drive(onNext: { [weak self] restoreImageList in
                self?.appendItemsToDataSource(with: restoreImageList)
            })
            .disposed(by: disposeBag)
    }
    
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
    
    private func createDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<PreviewCollectionViewCell,
                                                                 ImageInfo>(handler: makeCellRegistration())
        
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
        
        appendItemsToDataSource(with: viewModel.imageList)
    }
    
    private func makeCellRegistration() -> (_ cell: PreviewCollectionViewCell,
                                            _ indexPath: IndexPath, _
                                            itemIdentifier: ImageInfo) -> Void {
        return { [weak self] cell, _, image in
            guard let self = self else { return }
            cell.setImage(named: image.imageURL)
            cell.identifiter = image
            self.bindDeleteButton(to: cell)
            if self.firstLaunch {
                self.setInitialSelectedCell()
            }
        }
    }
    
    private func bindDeleteButton(to cell: PreviewCollectionViewCell) {
        cell.rx.deleteButtonDelegate
            .asObservable()
            .withUnretained(self)
            .bind(onNext: { owner, imageInfo in
                owner.deleteItemToDataSource(with: imageInfo)
                if let deletedItemIndex = owner.viewModel.deleteButtonDidTap(identifier: imageInfo) {
                    if deletedItemIndex == owner.viewModel.imageList.count {
                        owner.updateIndexLabel(row: deletedItemIndex - 1)
                    }
                    owner.updateCountLabel()
                    owner.moveCellToCenter()
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func appendItemsToDataSource(with imageList: [ImageInfo]) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, ImageInfo>()
        snapshot.appendSections([.previewList])
        snapshot.appendItems(imageList)
        dataSource.apply(snapshot)
        
        moveCellToCenter()
        updateCountLabel()
    }
    
    private func deleteItemToDataSource(with identifier: ImageInfo) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([identifier])
        dataSource.apply(snapshot)
    }
    
    private func moveCellToCenter() {
        let centerPoint = CGPoint(x: collectionView.contentOffset.x + collectionView.frame.size.width / 2, y: 0.0)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.imageView.setImage(with: viewModel.imageList[indexPath.row].imageURL)
            self.centerCell = self.collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell
            self.centerCell?.setSelectedUI()
            updateIndexLabel(row: indexPath.row)
        }
        
        setUnselectedCellUI()
    }
    
    private func setUnselectedCellUI() {
        let centerPoint =  CGPoint(x: collectionView.contentOffset.x + collectionView.frame.size.width / 2, y: 0.0)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            for row in 0..<viewModel.imageList.count where row != indexPath.row {
                let cell = self.collectionView.cellForItem(at: [0, row]) as? PreviewCollectionViewCell
                cell?.setUnselectedUI()
            }
        }
    }
    
    private func setInitialSelectedCell() {
        centerCell = self.collectionView.cellForItem(at: [0, 0]) as? PreviewCollectionViewCell
        if centerCell != nil {
            self.firstLaunch.toggle()
        }
        centerCell?.setSelectedUI()
        imageView.setImage(with: viewModel.imageList[0].imageURL)
    }
    
    private func updateCountLabel() {
        totalImageCountLabel.text = "\(viewModel.imageList.count)장"
    }
    
    private func updateIndexLabel(row: Int) {
        selectedIndexLabel.text = "\(row + 1)번"
    }
    
    // MARK: - Actions
    
    @objc
    private func saveButtonDidTap() {
        // TO DO: 동영상 저장 서버 연결
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension VideoEditViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isSelectedEvent { return }
        
        let centerPoint = CGPoint(x: collectionView.contentOffset.x + collectionView.frame.size.width / 2, y: 0.0)
        
        if let indexPath = collectionView.indexPathForItem(at: centerPoint), centerCell == nil {
            self.centerCell = self.collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell
            self.centerCell?.setSelectedUI()
            imageView.setImage(with: viewModel.imageList[indexPath.row].imageURL)
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        moveCellToCenter()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        moveCellToCenter()
        isSelectedEvent.toggle()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        if !decelerate {
            moveCellToCenter()
        }
    }
    
    // MARK: - CollecetionView Delegate
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = collectionView.frame.width / 2 - cellWidth / 2
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth / Constant.Size.figmaWidth * Constant.Size.screenWidth,
                      height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        isSelectedEvent = true
        guard let cell = collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell else { return }
        centerCell = cell
        collectionView.setContentOffset(CGPoint(x: cell.frame.minX - (collectionView.frame.width / 2 - cellWidth / 2),
                                                y: 0.0),
                                        animated: true)
        imageView.setImage(with: viewModel.imageList[indexPath.row].imageURL)
        updateIndexLabel(row: indexPath.row)
    }

}

// MARK: - Layout

extension VideoEditViewController {
    
    private func setupConstraint() {
        view.addSubviews(imageView, collectionView, totalImageCountLabel,
                         ofLabel, selectedIndexLabel, backingButton)
        
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
        
        backingButton.snp.makeConstraints {
            $0.top.equalTo(ofLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(10)
        }
    }
    
}

class ImageInfo: NSObject {
    let imageKey: String
    let imageURL: String
    
    init(imageKey: String, imageURL: String) {
        self.imageKey = imageKey
        self.imageURL = imageURL
    }
}
