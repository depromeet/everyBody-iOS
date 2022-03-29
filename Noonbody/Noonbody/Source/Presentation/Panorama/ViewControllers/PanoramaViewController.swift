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
import RealmSwift

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
        $0.register(BottomCollectionViewCell.self)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        $0.collectionViewLayout = layout
        $0.bounces = false
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
        $0.allowsMultipleSelection = false
        $0.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    private var stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = UIDevice.current.hasNotch ? 22 : 5
        $0.distribution = .fill
        $0.backgroundColor = .white
    }
    
    private var emptyView = AlbumEmptyView(type: .picture).then {
        $0.isHidden = true
        $0.button.addTarget(self, action: #selector(cameraButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - Properties
    
    let cellSpacing: CGFloat = 2
    var cellWidth: CGFloat = 0
    private let viewModel = PanoramaViewModel(fetchAlbumUseCase: DefaultFetchAlbumUseCase(repository: LocalAlbumRepositry()),
                                              renameAlbumUseCase: DefaultRenameAlbumUseCase(repository: LocalAlbumRepositry()),
                                              deleteAlbumUseCase: DefaultDeleteAlbumUseCase(repository: LocalAlbumRepositry()),
                                              deletePictureUseCase: DefaultDeletePictureUseCase(repository: LocalPictureRepository()))
    private var popUpForPicturesDeletion = PopUpViewController(type: .delete)
    private var popUpForAlbumDeletion = PopUpViewController(type: .delete)
    private var popUpForAlbumRenaming = PopUpViewController(type: .textField)
    private var cameraViewcontroller = CameraViewController()
    private var albumId: Int
    var albumData: Album
    private var albumName: String
    var bodyPartIndex = 0
    var bodyPart: BodyPart = .whole
    
    private var seletedPictures = BehaviorRelay<[Int: Int]>(value: [:])
    private var seletedPicturesValue: [Int: Int]
    
    var bodyPartData: [PictureInfo] {
        didSet {
            setHide()
            reloadCollectionView()
            editMode ? initEditNavigationBar() : initNavigationBar()
        }
    }
    
    var gridMode = false {
        didSet {
            topCollectionView.reloadData()
            topCollectionView.bounces = gridMode
            topCollectionView.isScrollEnabled = gridMode
            topCollectionView.allowsSelection = !gridMode
        }
    }
    
    var editMode = false {
        didSet {
            topCollectionView.reloadData()
            topCollectionView.isScrollEnabled = editMode
            topCollectionView.allowsMultipleSelection = editMode
            gridButton.isHidden = editMode
            setHide()
        }
    }
    
    private var verticalFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .vertical
    }
    
    private var horizontalFlowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
    }
    var centerCell: BottomCollectionViewCell?
    var selectedIndexByPart = Array(repeating: IndexPath(item: 0, section: 0), count: 3)
    var isSelectedEvent: Bool = false
    
    private lazy var menuItems: [UIAction] = [
        UIAction(title: "앨범 이름 수정",
                 image: Asset.Image.folderOpen.image,
                 handler: { _ in self.editAlbumButtonDidTap()}),
        UIAction(title: "앨범 삭제",
                 image: Asset.Image.delGray.image,
                 attributes: .destructive,
                 handler: { _ in self.deleteAlbumButtonDidTap()}),
        UIAction(title: "동영상 저장",
                 image: Asset.Image.shareGray.image,
                 handler: { _ in self.saveButtonDidTap() })
    ]
    
    // MARK: - View Life Cycle
    
    init(albumId: Int, albumData: Album) {
        self.albumId = albumId
        self.albumData = albumData
        self.bodyPartData = albumData.pictures.whole
        self.albumName = self.albumData.name
         
        self.seletedPicturesValue = seletedPictures.value
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        initNavigationBar()
        setupViewHierarchy()
        setupCollectionView()
        setDelegation()
        setupConstraint()
        initSegementData()
        setDefaultTab()
        render()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetDeleteData()
        editMode ? initEditNavigationBar() : initNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        setHide()
        bottomCollectionView.reloadData()
        moveCellToCenter(animated: false)
    }
    
    // MARK: - Methods
    
    private func bind() {
        let input = PanoramaViewModel.Input(cameraViewDidDisappear: cameraViewcontroller.rx.viewDidDisappear.map { _ in },
                                            albumId: albumId,
                                            albumNameTextField: popUpForAlbumRenaming.textField.rx.text.orEmpty.asObservable(),
                                            deletePictureData: seletedPictures.asObservable(),
                                            deletePictureButtonControlEvent: popUpForPicturesDeletion.confirmButton.rx.tap,
                                            deleteAlbumButtonControlEvent: popUpForAlbumDeletion.confirmButton.rx.tap,
                                            renameButtonControlEvent: popUpForAlbumRenaming.confirmButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.album
            .drive(onNext: { [weak self] data in
                guard let self = self else { return }
                if let data = data {
                    self.albumData = data
                    self.initBodyPartData(index: self.bodyPartIndex)
                }
                self.moveCellToCenter(animated: false)
            })
            .disposed(by: disposeBag)
        
        output.canRename
            .drive(popUpForAlbumRenaming.confirmButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.renamedAlbum
            .drive(onNext: { [weak self] name in
                guard let self = self else { return }
                if let name = name {
                    self.title = name
                    self.albumName = name
                    self.showToast(type: .save)
                }
            }).disposed(by: disposeBag)
        
        output.deletePictureCount
            .drive(onNext: { [weak self] count in
                guard let self = self else { return }
                self.title = self.editMode ? "\(count)장" : self.albumName
                    self.navigationItem.rightBarButtonItem?.isEnabled = count != 0
                }
            ).disposed(by: disposeBag)

        output.deletePictureStatusCode
            .drive(onNext: { [weak self] statusCode in
                guard let self = self else { return }
                if statusCode == 200 {
                    self.seletedPictures.value.forEach { key, value in
                        self.deleteAlbumData(id: value)
                        self.bodyPartData.removeAll(where: {$0.id == value})
                        self.seletedPicturesValue.removeValue(forKey: key)
                        self.seletedPictures.accept(self.seletedPicturesValue)
                        self.updateSeletedIndex(index: key)
                    }
                    self.showToast(type: .delete)
                    self.dismiss(animated: true, completion: self.topCollectionView.reloadData)
                }
            }).disposed(by: disposeBag)

        output.deleteAlbumStatusCode
            .drive(onNext: { [weak self] statusCode in
                guard let self = self else { return }
                if statusCode == 204 {
                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: false)
                }
            }).disposed(by: disposeBag)
    }
    
    private func initNavigationBar() {
        navigationController?.initNavigationBarWithMenu(navigationItem: self.navigationItem,
                                                        rightButtonImage: Asset.Image.create.image,
                                                        rightAction: #selector(editOrCloseButtonDidTap),
                                                        menuButtonImage: Asset.Image.option.image,
                                                        menuChildItem: menuItems)
        navigationItem.leftBarButtonItems = nil
        navigationItem.rightBarButtonItems?[1].customView?.isHidden = bodyPartData.isEmpty
        title = albumName
    }
    
    private func initEditNavigationBar() {
        navigationController?.initNavigationBar(navigationItem: self.navigationItem,
                                                leftButtonImages: [Asset.Image.clear.image],
                                                rightButtonImages: [Asset.Image.del.image],
                                                leftActions: [#selector(editOrCloseButtonDidTap)],
                                                rightActions: [#selector(deletePictureButtonDidTap)])
        
        self.title = "\(seletedPictures.value.count)장"
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func setDelegation() {
        bodyPartSegmentControl.delegate = self
        [topCollectionView, bottomCollectionView].forEach { collectionView in
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    private func setDefaultTab() {
        if albumData.pictures.whole.isEmpty {
            if !albumData.pictures.upper.isEmpty {
                bodyPartSegmentControl.buttons[0].isSelected = false
                bodyPartSegmentControl.buttons[1].isSelected = true
                bodyPartData = albumData.pictures.upper
                bodyPart = .upper
            } else if !albumData.pictures.lower.isEmpty {
                bodyPartSegmentControl.buttons[0].isSelected = false
                bodyPartSegmentControl.buttons[2].isSelected = true
                bodyPartData = albumData.pictures.lower
                bodyPart = .lower
            }
        }
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
            bodyPart = .whole
        case 1:
            bodyPartData = albumData.pictures.upper
            bodyPart = .upper
        case 2:
            bodyPartData = albumData.pictures.lower
            bodyPart = .lower
        default:
            return
        }
    }
    
    private func deleteAlbumData(id: Int) {
        switch bodyPart {
        case .whole:
            albumData.pictures.whole.removeAll(where: {$0.id == id})
        case .upper:
            albumData.pictures.upper.removeAll(where: {$0.id == id})
        case .lower:
            albumData.pictures.lower.removeAll(where: {$0.id == id})
        }
    }
    
    private func resetDeleteData() {
        seletedPictures.accept([:])
    }
    
    private func updateSeletedIndex(index: Int) {
        let lastIndexPathItem = selectedIndexByPart[bodyPartIndex].item
        var updatedIndexPathItem: Int
        
        if index == lastIndexPathItem {
            updatedIndexPathItem = lastIndexPathItem > 1 ? lastIndexPathItem - 1 : lastIndexPathItem
        } else {
            updatedIndexPathItem = index - lastIndexPathItem < 0 ? lastIndexPathItem - 1 : lastIndexPathItem
        }
        
        selectedIndexByPart[bodyPartIndex] = IndexPath(item: updatedIndexPathItem, section: 0)
    }
    
    private func switchPanoramaMode() {
        if gridMode || editMode {
            topCollectionView.setCollectionViewLayout(verticalFlowLayout, animated: false)
            bottomCollectionView.isHidden = true
        } else {
            topCollectionView.setCollectionViewLayout(horizontalFlowLayout, animated: false)
            bottomCollectionView.isHidden = false
            moveCellToCenter(animated: false)
        }
    }
    
    private func reloadCollectionView() {
        topCollectionView.reloadData()
        bottomCollectionView.reloadData()
    }
    
    private func setHide() {
        emptyView.isHidden = bodyPartData.isEmpty && !editMode ? false : true
        gridButton.isHidden = bodyPartData.isEmpty || editMode ? true : false
    }
    
    func moveCellToCenter(animated: Bool) {
        if !(bottomCollectionView.isHidden || bodyPartData.isEmpty) {
            bottomCollectionView.selectItem(at: selectedIndexByPart[bodyPartIndex], animated: false, scrollPosition: .centeredHorizontally)
            setCollectionViewContentOffset(animated: false)
        }
    }
    
    func setCollectionViewContentOffset(animated: Bool) {
        topCollectionView.setContentOffset(CGPoint(x: topCollectionView.frame.maxX * CGFloat(selectedIndexByPart[bodyPartIndex].row),
                                                   y: 0.0), animated: false)
        bottomCollectionView.setContentOffset(CGPoint(x: cellWidth * CGFloat(selectedIndexByPart[bodyPartIndex].row), y: 0.0), animated: animated)
    }
    
    private func editAlbumButtonDidTap() {
        setPopUpViewController(popUp: popUpForAlbumRenaming)
        popUpForAlbumRenaming.titleLabel.text = "앨범 이름을 수정해주세요."
        popUpForAlbumRenaming.textField.text = albumName
        popUpForAlbumRenaming.confirmButton.titleLabel?.font = .nbFont(type: .body1Bold)
        self.present(popUpForAlbumRenaming, animated: true, completion: nil)
    }
    
    private func deleteAlbumButtonDidTap() {
        setPopUpViewController(popUp: popUpForAlbumDeletion)
        popUpForAlbumDeletion.titleLabel.text = "정말 앨범을 삭제하시겠어요?"
        popUpForAlbumDeletion.descriptionLabel.text = "삭제를 누르면 앨범 속 사진이\n영구적으로 삭제됩니다."
        popUpForAlbumDeletion.setDeleteButton()
        self.present(popUpForAlbumDeletion, animated: true, completion: nil)
    }
    
    private func saveButtonDidTap() {
        bodyPartData.count > 1 ? pushVideoViewController() : presentWarningPopUp()
    }
    
    private func pushVideoViewController() {
//        var imageList: [(String, String)] = []
//        switch bodyPart {
//        case 0:
//            imageList = albumData.pictures.whole.map { ($0.key, $0.imageURL) }
//        case 1:
//            imageList = albumData.pictures.upper.map { ($0.key, $0.imageURL) }
//        case 2:
//            imageList = albumData.pictures.lower.map { ($0.key, $0.imageURL) }
//        default:
//            return
//        }
//        let viewController = VideoEditViewController(albumData: imageList, title: albumData.name)
//        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func presentWarningPopUp() {
        let popUp = PopUpViewController(type: .oneButton)
        setPopUpViewController(popUp: popUp)
        popUp.titleLabel.text = "사진이 최소 2장 이상 필요해요."
        popUp.descriptionLabel.text = "영상 저장하기를 이용하고 싶으시다면\n최소 2장의 사진을 업로드해 주세요."
        popUp.setCancelButtonTitle(text: "확인")
        popUp.cancelButton.titleLabel?.font = .nbFont(type: .body1Bold)
        popUp.cancelButton.setTitleColor(Asset.Color.keyPurple.color, for: .normal)
        self.present(popUp, animated: true, completion: nil)
    }
    
    private func setPopUpViewController(popUp: PopUpViewController) {
        popUp.modalTransitionStyle = .crossDissolve
        popUp.modalPresentationStyle = .overCurrentContext
        popUp.delegate = self
    }
    
    // MARK: - Actions
    @objc
    private func editOrCloseButtonDidTap() {
        resetDeleteData()
        editMode ? initNavigationBar() : initEditNavigationBar()
        editMode.toggle()
        if !gridMode {
            switchPanoramaMode()
        }
    }
    
    @objc
    private func deletePictureButtonDidTap() {
        setPopUpViewController(popUp: popUpForPicturesDeletion)
        popUpForPicturesDeletion.titleLabel.text = "\(seletedPictures.value.count)장의 사진을 삭제하시겠어요?"
        popUpForPicturesDeletion.descriptionLabel.text = "삭제를 누르시면 앨범에서\n영구 삭제가 됩니다."
        popUpForPicturesDeletion.setDeleteButton()
        self.present(popUpForPicturesDeletion, animated: true, completion: nil)
    }
    
    @objc
    private func gridButtonDidTap() {
        gridButton.isSelected.toggle()
        gridMode.toggle()
        switchPanoramaMode()
    }
    
    @objc func cameraButtonDidTap() {
        self.navigationController?.pushViewController(cameraViewcontroller, animated: true)
    }
    
}

// MARK: - View Layout

extension PanoramaViewController {
    private func setupCollectionView() {
        topCollectionView.collectionViewLayout = horizontalFlowLayout
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
        bodyPartIndex = index
        initBodyPartData(index: bodyPartIndex)
        resetDeleteData()
        if !bodyPartData.isEmpty {
            selectedIndexByPart[bodyPartIndex] = selectedIndexByPart[index]
            moveCellToCenter(animated: false)
        }
    }
}

extension PanoramaViewController: PopUpActionProtocol {
    func cancelButtonDidTap(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func confirmButtonDidTap(_ button: UIButton, textInfo: String) {
        self.dismiss(animated: true, completion: nil)
    }
}
