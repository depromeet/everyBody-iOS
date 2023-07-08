//
//  PanoramaAlbumViewController.swift
//  Noonbody
//
//  Created by kong on 2023/06/06.
//

import UIKit

import Then
import Mixpanel
import RxSwift
import RxCocoa

final class PanoramaAlbumViewController: BaseViewController {
    
    private var stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = UIDevice.current.hasNotch ? 22 : 5
        $0.distribution = .fill
        $0.backgroundColor = .clear
    }

    private var panoramaImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }

    private var bottomCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        $0.register(BottomCollectionViewCell.self)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        $0.collectionViewLayout = layout
        $0.bounces = false
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.allowsMultipleSelection = false
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    private lazy var popUpForPicturesDeletion = PopUpViewController(type: .delete).then {
        $0.confirmButton.addTarget(self, action: #selector(deletePictureCompleteButtonDidTap),
                                   for: .touchUpInside)
        $0.cancelButton.addTarget(self, action: #selector(deletePictureCancleButtonDidTap),
                                  for: .touchUpInside)
    }

    private var centerCell: BottomCollectionViewCell?
    private let cellSpacing: CGFloat = 2
    private var cellWidth: CGFloat = 0
    private var isSelectedEvent: Bool = false

    private var pictureInfos: [PictureInfo] {
        didSet {
            navigationItem.rightBarButtonItem?.isEnabled = !pictureInfos.isEmpty
        }
    }
    private var bodyPart: BodyPart
    private var pictureIndex: IndexPath {
        didSet {
            if !pictureInfos.isEmpty {
                selectedPictureId.accept(pictureInfos[pictureIndex.row].id)
            }
        }
    }
    private var pictureIndexPath: IndexPath = IndexPath(item: -1, section: 0)
    private var selectedPictureId = PublishRelay<Int>()

    private var viewModel: PanoramaAlbumViewModel = PanoramaAlbumViewModel(deletePictureUseCase: DefaultDeletePictureUseCase(repository: LocalPictureRepository()))
    
    init(pictureInfos: [PictureInfo], bodyPart: BodyPart, pictureIndex: IndexPath) {
        self.pictureInfos = pictureInfos
        self.bodyPart = bodyPart
        self.pictureIndex = pictureIndex
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        bind()
        setupConstraint()
        collectionViewDelegation()
    }

    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }

    private func setupView() {
        selectedPictureId.accept(pictureInfos[pictureIndex.row].id)
        setupPanormaImageView(pictureIndex: pictureIndex.row)
        moveCellToCenter(animated: false)
    }

    private func collectionViewDelegation() {
        bottomCollectionView.delegate = self
        bottomCollectionView.dataSource = self
    }

    private func initNavigationBar() {
        navigationController?.initNavigationBar(navigationItem: self.navigationItem,
                                                rightButtonImages: [Asset.Image.trash.image],
                                                rightActions: [#selector(deletePictureButtonDidTap)])
        navigationItem.leftBarButtonItems = nil
        title = bodyPart.title
    }

    private func bind() {
        let input = PanoramaAlbumViewModel.Input(deletePictureId: selectedPictureId.asObservable(),
                                                 deletePictureButtonControlEvent: popUpForPicturesDeletion.confirmButton.rx.tap)
        let output = viewModel.transform(input: input)
        output.deletePictureStatusCode
            .drive(onNext: { [weak self] statusCode in
                guard let self else { return }
                if statusCode == 200 {
                    self.showToast(type: .delete)
                    self.dismiss(animated: true, completion: bottomCollectionView.reloadData)
                }
            })
            .disposed(by: disposeBag)

        output.deletedPictureId
            .drive(onNext: { [weak self] id in
                guard let self else { return }
                pictureInfos.removeAll(where: { $0.id == id })
                bottomCollectionView.reloadData()
                pictureIndex = pictureIndex.row > 0 ? IndexPath(item: (pictureIndex.row) - 1, section: 0) : pictureIndex
                setupPanormaImageView(pictureIndex: pictureIndex.row)
                moveCellToCenter(animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func setupConstraint() {
        view.addSubviews(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        stackView.addArrangedSubviews([panoramaImageView, bottomCollectionView])
        panoramaImageView.snp.makeConstraints {
            let ratio = UIDevice.current.hasNotch ? (4.0/3.0) : (423/375)
            $0.height.equalTo(Constant.Size.screenWidth * ratio).priority(999)
        }
    }

    private func setupPanormaImageView(pictureIndex: Int) {
        if pictureInfos.isEmpty {
            panoramaImageView.image = nil
        } else {
            panoramaImageView.image = AlbumManager.loadImageFromDocumentDirectory(from: "\(pictureInfos[pictureIndex].albumID)/\(pictureInfos[pictureIndex].bodyPart)/\(pictureInfos[pictureIndex].id).\(FileExtension.png)")
        }
    }

    @objc private func deletePictureButtonDidTap() {
        popUpForPicturesDeletion.modalTransitionStyle = .crossDissolve
        popUpForPicturesDeletion.modalPresentationStyle = .overCurrentContext
        popUpForPicturesDeletion.delegate = self
        popUpForPicturesDeletion.titleLabel.text = "사진을 삭제하시겠습니까?"
        popUpForPicturesDeletion.descriptionLabel.text = "삭제를 누르시면 사진이 완전히 삭제됩니다."
        popUpForPicturesDeletion.setDeleteButton()
        self.present(popUpForPicturesDeletion, animated: true, completion: nil)

        Mixpanel.mainInstance().track(event: "selectPhoto/btn/delete")
    }

    @objc func deletePictureCancleButtonDidTap() {
        Mixpanel.mainInstance().track(event: "selectPhoto/deletePhotoModal/btn/cancle")
    }
    @objc func deletePictureCompleteButtonDidTap() {
        Mixpanel.mainInstance().track(event: "selectPhoto/deletePhotoModal/btn/complete")
    }

    func moveCellToCenter(animated: Bool) {
        if !pictureInfos.isEmpty {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                bottomCollectionView.scrollToItem(at: pictureIndex, at: .centeredHorizontally, animated: animated)
            }
        }
    }
}

// MARK: - Extension

extension PanoramaAlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellWidth = collectionView.frame.height * 0.54 + cellSpacing
        return CGSize(width: cellWidth, height: collectionView.frame.height )
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = (collectionView.frame.width - (collectionView.frame.height * 0.54 + cellSpacing)) / 2
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isSelectedEvent { return }

        if !pictureInfos.isEmpty {
            let centerPoint = CGPoint(x: bottomCollectionView.contentOffset.x + bottomCollectionView.frame.midX, y: 100)
            if let indexPath = bottomCollectionView.indexPathForItem(at: centerPoint), centerCell == nil {
                centerCell = bottomCollectionView.cellForItem(at: indexPath) as? BottomCollectionViewCell
                setupPanormaImageView(pictureIndex: indexPath.row)
                pictureIndex = indexPath
                pictureIndexPath = indexPath
                centerCell?.transformToCenter()
            }

            if let cell = centerCell {
                let offsetX = centerPoint.x - cell.center.x
                if offsetX < -cell.frame.width/2 || offsetX > cell.frame.width/2 {
                    cell.transformToStandard()
                    bottomCollectionView.deselectItem(at: pictureIndex, animated: false)
                    self.centerCell = nil
                }
            }
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        moveCellToCenter(animated: true)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isSelectedEvent = false
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            moveCellToCenter(animated: true)
        }
    }
}

extension PanoramaAlbumViewController: UICollectionViewDataSource {
    typealias CameraCell = CameraCollectionViewCell
    typealias BottomCell = BottomCollectionViewCell

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictureInfos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BottomCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.setCell(albumId: pictureInfos[indexPath.row].albumID,
                     bodyPart: pictureInfos[indexPath.row].bodyPart.rawValue,
                     imageName: pictureInfos[indexPath.row].id,
                     index: indexPath.row,
                     fileExtension: .png)

        if indexPath.item == pictureIndex.row {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .init())
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !pictureInfos.isEmpty {
            moveCellToCenter(animated: true)
            if pictureIndex == indexPath { return }
            isSelectedEvent = true
            centerCell?.transformToStandard()
            pictureIndex = indexPath
            pictureIndexPath = indexPath
            setupPanormaImageView(pictureIndex: indexPath.row)

            guard let bottomCell = bottomCollectionView.cellForItem(at: indexPath) as? BottomCollectionViewCell else { return }
            centerCell = bottomCell
        }
    }
}

extension PanoramaAlbumViewController: PopUpActionProtocol {
    func cancelButtonDidTap(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
        Mixpanel.mainInstance().track(event: "selectPhoto/deletePhotoModal/btn/cancle")
    }

    func confirmButtonDidTap(_ button: UIButton, textInfo: String) {
        self.dismiss(animated: true, completion: nil)
        Mixpanel.mainInstance().track(event: "selectPhoto/deletePhotoModal/btn/complete")
    }
}
