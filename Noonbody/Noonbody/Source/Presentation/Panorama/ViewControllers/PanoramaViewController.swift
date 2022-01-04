//
//  PanoramaViewController.swift
//  everyBody-iOS
//
//  Created by kong on 2021/10/30.
//

import UIKit

import SnapKit
import Then
import RxSwift
import RxRelay

class PanoramaViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private var gridButton = UIButton().then {
        $0.setImage(Asset.Image.grid.image, for: .normal)
        $0.setImage(Asset.Image.list.image, for: .selected)
        $0.addTarget(self, action: #selector(gridButtonDidTap), for: .touchUpInside)
    }
    
    private let bodyPartSegmentControl = NBSegmentedControl(buttonStyle: .basic, numOfButton: 3).then {
        $0.spacing = 10
    }
    
    var topCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        $0.register(TopCollectionViewCell.self)
        $0.register(CameraCollectionViewCell.self)
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
        $0.bounces = false
        $0.isScrollEnabled = false
    }
    
    var bottomCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        $0.bounces = false
        $0.register(BottomCollectionViewCell.self)
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
        $0.allowsMultipleSelection = false
        $0.collectionViewLayout = layout
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    private var stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = UIDevice.current.hasNotch ? 22 : 5
        $0.distribution = .fill
        $0.backgroundColor = .white
    }
    
    private var emptyView = AlbumEmptyView(type: .picture).then {
        $0.button.addTarget(self, action: #selector(cameraButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - Properties
    
    private let viewModel = PanoramaViewModel(panoramaUseCase: DefaultPanoramaUseCase(panoramaRepository: DefaultPanoramaRepository()))
    private var popupViewController = PopUpViewController(type: .delete)
    private var bodyPart = 0
    private var albumId: Int
    private var albumData: Album
    var deleteData: [Int] = [] {
        didSet {
            navigationItem.rightBarButtonItem?.isEnabled = !deleteData.isEmpty ? true : false
        }
    }
    var bodyPartData: [PictureInfo] = [] {
        didSet {
            topCollectionView.reloadData()
            bottomCollectionView.reloadData()
            initNavigationBar()
            emptyView.isHidden = !bodyPartData.isEmpty ? true : false
            gridButton.isHidden = bodyPartData.isEmpty ? true : false
            if !bodyPartData.isEmpty {
                bottomCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    var gridMode = false {
        didSet {
            topCollectionView.reloadData()
            if gridMode {
                topCollectionView.bounces = true
                topCollectionView.isScrollEnabled = true
                topCollectionView.allowsSelection = false
            } else {
                topCollectionView.allowsSelection = true
                topCollectionView.bounces = false
                topCollectionView.isScrollEnabled = false
                bottomCollectionView.scrollToItem(at: tagSelectedIdx, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    var editMode = false {
        didSet {
            topCollectionView.reloadData()
            topCollectionView.allowsMultipleSelection = editMode
            topCollectionView.isScrollEnabled = editMode
            gridButton.isHidden = editMode
        }
    }
    
    private var verticalFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
    }
    
    private var horizontalFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
    }
    
    var tagSelectedIdx = IndexPath(row: 0, section: 0)
    var centerCell: BottomCollectionViewCell?
    
    // MARK: - View Life Cycle
    
    init(albumId: Int, albumData: Album) {
        self.albumId = albumId
        self.albumData = albumData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        initNavigationBar()
        setupViewHierarchy()
        setupCollectionView()
        setupConstraint()
        initSegementData()
        initSegmentedControl()
        render()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initBottomCollectionView()
    }
    
    // MARK: - Methods
    func bind() {
        bodyPartSegmentControl.buttons[0].rx.tap
        
        popupViewController.confirmButton.rx.tap
            .subscribe(onNext: {
                self.deleteData.forEach { data in
                    DefaultAlbumUseCase(albumRepository: DefaultAlbumRepositry())
                        .deletePicture(pictureId: data).bind(onNext: { [weak self] statusCode in
                            guard let self = self else { return }
                            if statusCode == 200 {
                                self.showToast(type: .delete)
                            }
                        }).disposed(by: self.disposeBag)
                    
                    self.bodyPartData.removeAll(where: {$0.id == data})
                }
                self.deleteData = []
                self.dismiss(animated: true, completion: self.topCollectionView.reloadData)
            }).disposed(by: disposeBag)
        
        let input = PanoramaViewModel.Input(viewWillAppear: rx.viewWillAppear.map { _ in }, albumId: albumId)
        let output = viewModel.transeform(input: input)
        
        output.album
            .drive(onNext: { [weak self] data in
                guard let self = self else { return }
                if let data = data {
                    self.albumData = data
                    self.initBodyPartData(index: self.bodyPart)
                }
                self.emptyView.isHidden = !self.bodyPartData.isEmpty ? true : false
            })
            .disposed(by: disposeBag)
    }
    
    private func initNavigationBar() {
        if bodyPartData.isEmpty {
            navigationItem.rightBarButtonItems = nil
        } else {
            navigationController?.initNavigationBar(navigationItem: self.navigationItem,
                                                rightButtonImages: [Asset.Image.share.image,
                                                                    Asset.Image.create.image],
                                                rightActions: [#selector(tapSaveButton),
                                                               #selector(tapEditOrCloseButton)])
        }
        navigationItem.leftBarButtonItems = nil
        title = albumData.name
    }
    
    private func initEditNavigationBar() {
        navigationController?.initNavigationBar(navigationItem: self.navigationItem,
                                                leftButtonImages: [Asset.Image.clear.image],
                                                rightButtonImages: [Asset.Image.del.image],
                                                leftActions: [#selector(tapEditOrCloseButton)],
                                                rightActions: [#selector(tapDeleteButton)])
        
        self.title = "\(bodyPartData.count)장"
        navigationItem.rightBarButtonItem?.isEnabled = false
        
    }
    
    private func initSegmentedControl() {
        bodyPartSegmentControl.delegate = self
    }
    
    private func initSegementData() {
        let bodyPartsArray = ["전신", "상체", "하체"]
        for (index, title) in bodyPartsArray.enumerated() {
            bodyPartSegmentControl.setTitle(at: index, title: title)
        }
    }
    
    private func initBodyPartData(index: Int) {
        switch index {
        case 0:
            bodyPartData = albumData.pictures.whole
        case 1:
            bodyPartData = albumData.pictures.upper
        case 2:
            bodyPartData = albumData.pictures.lower
        default:
            return
        }
    }
    
    private func initBottomCollectionView() {
        centerCell = bottomCollectionView.cellForItem(at: tagSelectedIdx) as? BottomCollectionViewCell
        centerCell?.transformToCenter()
    }
    
    private func switchPanoramaMode() {
        if gridMode || editMode {
            topCollectionView.setCollectionViewLayout(verticalFlowLayout, animated: false)
            bottomCollectionView.isHidden = true
        } else {
            topCollectionView.setCollectionViewLayout(horizontalFlowLayout, animated: false)
            bottomCollectionView.isHidden = false
        }
        
        self.view.layoutIfNeeded()
        bottomCollectionView.scrollToItem(at: tagSelectedIdx, at: .centeredHorizontally, animated: true)
    }
    
    // MARK: - Actions
    @objc
    private func tapEditOrCloseButton() {
        editMode ? initNavigationBar() : initEditNavigationBar()
        editMode.toggle()
        if !gridMode {
            switchPanoramaMode()
        }
    }
    
    @objc
    private func tapSaveButton() {
        /// init 내비에서 saveButton 눌렀을 때 처리
    }
    
    @objc
    private func tapDeleteButton() {
        let popUp = popupViewController
        popUp.modalTransitionStyle = .crossDissolve
        popUp.modalPresentationStyle = .overCurrentContext
        popUp.delegate = self
        popUp.titleLabel.text = "\(deleteData.count)장의 사진을 삭제하시겠어요?"
        popUp.descriptionLabel.text = "삭제를 누르시면 앨범에서\n영구 삭제가 됩니다."
        self.present(popUp, animated: true, completion: nil)
    }
    
    @objc
    private func gridButtonDidTap() {
        gridButton.isSelected.toggle()
        gridMode.toggle()
        switchPanoramaMode()
    }
    
    @objc func cameraButtonDidTap() {
        let viewController = CameraViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

// MARK: - View Layout

extension PanoramaViewController {
    private func setupCollectionView() {
        topCollectionView.collectionViewLayout = horizontalFlowLayout
        [topCollectionView, bottomCollectionView].forEach { collectionView in
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    private func setupViewHierarchy() {
        view.addSubviews(bodyPartSegmentControl, gridButton, stackView, emptyView)
        stackView.addArrangedSubviews([topCollectionView, bottomCollectionView])
    }
    
    private func setupConstraint() {
        bodyPartSegmentControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(22)
            $0.width.equalTo(152)
        }
        
        gridButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.trailing.equalToSuperview().offset(-22)
            $0.height.width.equalTo(24)
            $0.centerY.equalTo(bodyPartSegmentControl)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(bodyPartSegmentControl.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        topCollectionView.snp.makeConstraints {
            let ratio = UIDevice.current.hasNotch ? (4.0/3.0) : (423/375)
            $0.height.equalTo(Constant.Size.screenWidth * ratio).priority(999)
        }
        
        emptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(270 * Constant.Size.screenWidth / Constant.Size.figmaWidth)
            $0.height.equalTo(136 * Constant.Size.screenWidth / Constant.Size.figmaWidth)
        }
    }
}

// MARK: - Extension

extension PanoramaViewController: NBSegmentedControlDelegate {
    func changeToIndex(_ segmentControl: NBSegmentedControl, at index: Int) {
        bodyPart = index
        initBodyPartData(index: bodyPart)
        initNavigationBar()
    }
}

extension PanoramaViewController: PopUpActionProtocol {
    func cancelButtonDidTap(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

