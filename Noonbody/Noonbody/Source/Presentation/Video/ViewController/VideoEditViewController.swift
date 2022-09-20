//
//  VideoEditViewController.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/11.
//

import UIKit
import Photos

import RxCocoa
import RxSwift
import Mixpanel

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
    
    private var dataSource: UICollectionViewDiffableDataSource<SectionKind, String>! = nil
    private var collectionView: UICollectionView!
    private var centerCell: PreviewCollectionViewCell?
    private var previewImageView = UIImageView()
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
        $0.setImage(Asset.Image.back02.image, for: .normal)
    }
    private let saveBarButtonItem = UIBarButtonItem(image: Asset.Image.shareWhite.image,
                                                        style: .plain,
                                                        target: self,
                                                        action: nil)
    
    // MARK: - Initializer
    
    init(imagePaths: [String], albumData: [(String, String)], title: String) {
        viewModel = VideoViewModel(images: imagePaths,
                                   videoUsecase: DefaultVideoUseCase(videoRepository: DefaultVideoRepository()))
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
    
    override func viewWillAppear(_ animated: Bool) {
        isPushed = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !isPushed {
            Mixpanel.mainInstance().track(event: "saveVideo/btn/back")
        }
    }
    
    // MARK: - Methods
    
    private func bind() {
        let input = VideoViewModel.Input(backingButtonControlEvent: backingButton.rx.tap,
                                         saveButtonControlEvent: saveBarButtonItem.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.imageList
            .drive(onNext: { [weak self] restoreImageList in
                self?.appendItemsToDataSource(with: restoreImageList)
            })
            .disposed(by: disposeBag)
        
        output.isSaved
            .drive(onNext: { [weak self] save in
                guard let self = self else { return }
                let popUp = PopUpViewController(type: .download)
                if save {
                    popUp.modalTransitionStyle = .crossDissolve
                    popUp.modalPresentationStyle = .overCurrentContext
                    popUp.delegate = self
                    popUp.downloadedPercentView.setCompletedView()
                    popUp.titleLabel.text = "비디오 저장 완료!"
                    popUp.descriptionLabel.text = "비디오 저장이 완료되었어요!\n아이폰 앨범에서 저장된 비디오를 확인해 보세요."
                    popUp.cancelButton.setTitle("확인", for: .normal)
                    self.present(popUp, animated: true, completion: nil)
                    Mixpanel.mainInstance().track(event: "saveVideo/saveModal/btn/confirm")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func saveVideoInCameraRoll() {
        guard let fileURL = videfileURL else { return }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
        })
    }
    
    private func initNavigationBar() {
        navigationController?.initNaviBarWithBackButton(tintColor: .white)
        navigationItem.rightBarButtonItem = saveBarButtonItem
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
                                                                 String>(handler: makeCellRegistration())
        dataSource = UICollectionViewDiffableDataSource<SectionKind, String>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                return collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: item
                )
            }
        )
        appendItemsToDataSource(with: viewModel.imagePaths)
    }
    
    private func makeCellRegistration() -> (_ cell: PreviewCollectionViewCell,
                                            _ indexPath: IndexPath, _
                                            itemIdentifier: String) -> Void {
        return { [weak self] cell, _, image in
            guard let self = self else { return }
            cell.setImage(named: image)
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
                    if deletedItemIndex == owner.viewModel.imagePaths.count {
                        owner.updateIndexLabel(row: deletedItemIndex - 1)
                    }
                    owner.updateCountLabel()
                    owner.moveCellToCenter()
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func appendItemsToDataSource(with imageList: [String]) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, String>()
        snapshot.appendSections([.previewList])
        snapshot.appendItems(imageList)
        dataSource.apply(snapshot)
        
        moveCellToCenter()
        updateCountLabel()
    }
    
    private func deleteItemToDataSource(with identifier: String) {
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([identifier])
        dataSource.apply(snapshot)
    }
    
    private func moveCellToCenter() {
        let centerPoint = CGPoint(x: collectionView.contentOffset.x + collectionView.frame.size.width / 2, y: 0.0)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.previewImageView.image = AlbumManager.loadImageFromDocumentDirectory(from: viewModel.imagePaths[indexPath.row])
            self.centerCell = self.collectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell
            self.centerCell?.setSelectedUI()
            updateIndexLabel(row: indexPath.row)
        }
        
        setUnselectedCellUI()
    }
    
    private func setUnselectedCellUI() {
        let centerPoint =  CGPoint(x: collectionView.contentOffset.x + collectionView.frame.size.width / 2, y: 0.0)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            for row in 0..<viewModel.imagePaths.count where row != indexPath.row {
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
        previewImageView.image = AlbumManager.loadImageFromDocumentDirectory(from: viewModel.imagePaths[0])
    }
    
    private func updateCountLabel() {
        totalImageCountLabel.text = "\(viewModel.imagePaths.count)장"
    }
    
    private func updateIndexLabel(row: Int) {
        selectedIndexLabel.text = "\(row + 1)번"
    }
    
    private func presentShareSheet() {
        guard let fileURL = videfileURL else { return }
        let objectToShare = [fileURL]
        
        let activityViewController = UIActivityViewController(activityItems: objectToShare,
                                                              applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
}

extension VideoEditViewController: PopUpActionProtocol {
    
    func cancelButtonDidTap(_ button: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name("requestCancel"),
                                        object: nil)
        dismiss(animated: true, completion: nil)
        isPushed = true // 임의로 pop 시키는 것이기 때문에 back 이벤트 트래킹 하지 않기 위함
        self.navigationController?.popViewController(animated: true)
    }
    
    func confirmButtonDidTap(_ button: UIButton) {
        dismiss(animated: true, completion: nil)
        presentShareSheet()
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
            previewImageView.image = AlbumManager.loadImageFromDocumentDirectory(from: viewModel.imagePaths[indexPath.row])
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
        centerCell?.setUnselectedUI()
        centerCell = cell
        cell.setSelectedUI()
        collectionView.setContentOffset(CGPoint(x: cell.frame.minX - (collectionView.frame.width / 2 - cellWidth / 2),
                                                y: 0.0),
                                        animated: true)
        previewImageView.image = AlbumManager.loadImageFromDocumentDirectory(from: viewModel.imagePaths[indexPath.row])
        updateIndexLabel(row: indexPath.row)
    }

}

// MARK: - Layout

extension VideoEditViewController {
    
    private func setupConstraint() {
        view.addSubviews(previewImageView, collectionView, totalImageCountLabel,
                         ofLabel, selectedIndexLabel, backingButton)
        
        previewImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constant.Size.screenWidth * (4.0/3.0))
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(previewImageView.snp.bottom).offset(UIDevice.current.hasNotch ? 28 : 5)
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
            $0.centerX.equalToSuperview()
        }
    }
    
}
