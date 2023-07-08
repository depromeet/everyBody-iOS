//
//  GridAlbumViewController.swift
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
import Mixpanel

class GridAlbumViewController: BaseViewController {
    
    // MARK: - UI Components

    private let bodyPartSegmentControl = NBSegmentedControl(buttonStyle: .basic, numOfButton: 3).then {
        $0.spacing = 10
    }
    
    private var gridAlbumCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.scrollDirection = .vertical
        $0.collectionViewLayout = collectionViewFlowLayout
        $0.register(TopCollectionViewCell.self)
        $0.register(CameraCollectionViewCell.self)
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.bounces = true
    }
    private lazy var emptyView = AlbumEmptyView(type: .picture).then {
        $0.isHidden = true
        $0.button.addTarget(self, action: #selector(cameraButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - Properties
    
    private let cellSpacing: CGFloat = 2
    private var cellWidth: CGFloat = 0
    private let viewModel = GridAlbumViewModel(fetchAlbumUseCase: DefaultFetchAlbumUseCase(repository: LocalAlbumRepositry()),
                                              renameAlbumUseCase: DefaultRenameAlbumUseCase(repository: LocalAlbumRepositry()),
                                              deleteAlbumUseCase: DefaultDeleteAlbumUseCase(repository: LocalAlbumRepositry()),
                                              deletePictureUseCase: DefaultDeletePictureUseCase(repository: LocalPictureRepository()))
    private lazy var popUpForPicturesDeletion = PopUpViewController(type: .delete).then {
        $0.confirmButton.addTarget(self, action: #selector(deletePictureCompleteButtonDidTap), for: .touchUpInside)
        $0.cancelButton.addTarget(self, action: #selector(deletePictureCancleButtonDidTap), for: .touchUpInside)
    }
    private lazy var popUpForAlbumDeletion = PopUpViewController(type: .delete).then {
        $0.confirmButton.addTarget(self, action: #selector(deleteAlbumCompleteButtonDidTap), for: .touchUpInside)
        $0.cancelButton.addTarget(self, action: #selector(deleteAlbumCancleButtonDidTap), for: .touchUpInside)
    }
    private lazy var popUpForAlbumRenaming = PopUpViewController(type: .textField).then {
        $0.confirmButton.addTarget(self, action: #selector(renameAlbumCompleteButtonDidTap), for: .touchUpInside)
        $0.cancelButton.addTarget(self, action: #selector(renameAlbumCancleButtonDidTap), for: .touchUpInside)
    }
    private var cameraViewcontroller = CameraViewController()
    private var albumId: Int
    private var albumData: Album
    private var albumName: String
    private var bodyPartIndex = 0
    private var bodyPart: BodyPart = .whole
    private var seletedPictures = BehaviorRelay<[Int: Int]>(value: [:])
    private var seletedPicturesValue: [Int: Int]
    
    private var bodyPartData: [PictureInfo] {
        didSet {
            setHide()
            gridAlbumCollectionView.reloadData()
            editMode ? initEditNavigationBar() : initNavigationBar()
        }
    }
    
    private var gridMode = true {
        didSet {
            gridAlbumCollectionView.reloadData()
            gridAlbumCollectionView.bounces = gridMode
            gridAlbumCollectionView.allowsSelection = !gridMode
        }
    }
    
    private var editMode = false {
        didSet {
            gridAlbumCollectionView.reloadData()
            gridAlbumCollectionView.allowsMultipleSelection = editMode
            setHide()
        }
    }

    private var centerCell: BottomCollectionViewCell?
    private var selectedIndexByPart = Array(repeating: IndexPath(item: 0, section: 0), count: 3)
    private var isSelectedEvent: Bool = false
    private lazy var menuItems: [UIAction] = [
        UIAction(title: "사진 선택",
                 image: Asset.Image.done.image,
                 handler: { _ in self.editOrCloseButtonDidTap()}),
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
        isPushed = false
    }
    
    override func viewDidLayoutSubviews() {
        setHide()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !isPushed {
            Mixpanel.mainInstance().track(event: "viewAlbum/btn/back")
        }
    }

    // MARK: - Methods
    
    private func bind() {
        let input = GridAlbumViewModel.Input(viewWillAppear: rx.viewWillAppear.map { _ in },
                                            albumId: albumId,
                                            albumNameTextField: popUpForAlbumRenaming.textField.rx.text.orEmpty.asObservable(),
                                            deletePictureData: seletedPictures.asObservable(),
                                            deletePictureButtonControlEvent: popUpForPicturesDeletion.confirmButton.rx.tap,
                                            deleteAlbumButtonControlEvent: popUpForAlbumDeletion.confirmButton.rx.tap,
                                            renameButtonControlEvent: popUpForAlbumRenaming.confirmButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.album
            .drive(onNext: { [weak self] data in
                guard let self else { return }
                if let data = data {
                    self.albumData = data
                    self.initBodyPartData(index: self.bodyPartIndex)
                }
            })
            .disposed(by: disposeBag)
        
        output.canRename
            .drive(popUpForAlbumRenaming.confirmButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.renamedAlbum
            .drive(onNext: { [weak self] name in
                guard let self else { return }
                if let name = name {
                    self.title = name
                    self.albumName = name
                    self.showToast(type: .save)
                }
            }).disposed(by: disposeBag)
        
        output.deletePictureCount
            .drive(onNext: { [weak self] count in
                guard let self else { return }
                self.title = self.editMode ? "\(count)장" : self.albumName
                if self.editMode {
                    self.navigationItem.rightBarButtonItem?.isEnabled = count > 0
                }
            }).disposed(by: disposeBag)

        output.deletePictureStatusCode
            .drive(onNext: { [weak self] statusCode in
                guard let self else { return }
                if statusCode == 200 {
                    seletedPictures.value.forEach { key, value in
                        self.deleteAlbumData(id: value)
                        self.bodyPartData.removeAll(where: {$0.id == value})
                        self.seletedPicturesValue.removeValue(forKey: key)
                        self.seletedPictures.accept(self.seletedPicturesValue)
                        self.updateSeletedIndex(index: key)
                    }
                    self.showToast(type: .delete)
                    self.dismiss(animated: true, completion: self.gridAlbumCollectionView.reloadData)
                }
            }).disposed(by: disposeBag)

        output.deleteAlbumStatusCode
            .drive(onNext: { [weak self] statusCode in
                guard let self else { return }
                if statusCode == 204 {
                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: false)
                }
            }).disposed(by: disposeBag)
    }
    
    private func initNavigationBar() {
        navigationController?.initNavigationBarWithMenu(navigationItem: self.navigationItem,
                                                        action: #selector(menuButtonDidTap),
                                                        menuButtonImage: Asset.Image.option.image,
                                                        menuChildItem: getMenuItems())
        navigationItem.leftBarButtonItems = nil
        title = albumName
    }
    
    private func getMenuItems() -> [UIAction] {
        var items = menuItems
        if bodyPartData.isEmpty {
            items.remove(at: 0)
        }
        return items
    }
    
    private func initEditNavigationBar() {
        navigationController?.initNavigationBar(navigationItem: self.navigationItem,
                                                leftButtonImages: [Asset.Image.clear.image],
                                                rightButtonImages: [Asset.Image.del.image],
                                                leftActions: [#selector(editOrCloseButtonDidTap)],
                                                rightActions: [#selector(deletePictureButtonDidTap)])
        
        self.title = "\(seletedPictures.value.count)장"
        navigationItem.rightBarButtonItems?[0].isEnabled = seletedPictures.value.count > 0
    }
    
    private func setDelegation() {
        bodyPartSegmentControl.delegate = self
        gridAlbumCollectionView.delegate = self
        gridAlbumCollectionView.dataSource = self
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
        let bodyPartsArray: [BodyPart] = [.whole, .upper, .lower]

        for (index, bodyPart) in bodyPartsArray.enumerated() {
            bodyPartSegmentControl.setTitle(at: index, title: bodyPart.title)
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
        Mixpanel.mainInstance().track(event: "selectPhoto/tab/\(bodyPart.rawValue)")
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
    
    private func setHide() {
        emptyView.isHidden = bodyPartData.isEmpty && !editMode ? false : true
    }
    
    private func editAlbumButtonDidTap() {
        setPopUpViewController(popUp: popUpForAlbumRenaming)
        popUpForAlbumRenaming.titleLabel.text = "앨범 이름을 수정해주세요."
        popUpForAlbumRenaming.textField.text = albumName
        popUpForAlbumRenaming.confirmButton.titleLabel?.font = .nbFont(type: .body1Bold)
        self.present(popUpForAlbumRenaming, animated: true, completion: nil)
        
        Mixpanel.mainInstance().track(event: "viewAlbum/dropDown/editAlbumName")
    }
    
    private func deleteAlbumButtonDidTap() {
        setPopUpViewController(popUp: popUpForAlbumDeletion)
        popUpForAlbumDeletion.titleLabel.text = "정말 앨범을 삭제하시겠어요?"
        popUpForAlbumDeletion.descriptionLabel.text = "삭제를 누르면 앨범 속 사진이\n영구적으로 삭제됩니다."
        popUpForAlbumDeletion.setDeleteButton()
        self.present(popUpForAlbumDeletion, animated: true, completion: nil)
        
        Mixpanel.mainInstance().track(event: "viewAlbum/dropDown/deleteAlbum")
    }
    
    private func saveButtonDidTap() {
        bodyPartData.count > 1 ? pushVideoViewController() : presentWarningPopUp()
        
        Mixpanel.mainInstance().track(event: "viewAlbum/dropDown/saveVideo")
    }
    
    private func pushVideoViewController() {
        let imagePaths = AlbumManager.makePaths(albumId: albumData.id, pictureInfos: bodyPartData, fileExtension: .png)
        let viewController = VideoEditViewController(imagePaths: imagePaths,
                                                     albumData: [],
                                                     title: albumData.name)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func presentWarningPopUp() {
        let popUp = PopUpViewController(type: .oneButton)
        setPopUpViewController(popUp: popUp)
        popUp.titleLabel.text = "사진이 최소 2장 이상 필요해요."
        popUp.descriptionLabel.text = "영상 저장하기를 이용하고 싶으시다면\n최소 2장의 사진을 업로드해 주세요."
        popUp.setCancelButtonTitle(text: "확인")
        popUp.cancelButton.titleLabel?.font = .nbFont(type: .body1Bold)
        popUp.cancelButton.setTitleColor(Asset.Color.Primary.main.color, for: .normal)
        self.present(popUp, animated: true, completion: nil)
    }
    
    private func setPopUpViewController(popUp: PopUpViewController) {
        popUp.modalTransitionStyle = .crossDissolve
        popUp.modalPresentationStyle = .overCurrentContext
        popUp.delegate = self
    }
    
    // MARK: - Actions
    @objc private func editOrCloseButtonDidTap() {
        resetDeleteData()
        editMode ? initNavigationBar() : initEditNavigationBar()
        editMode.toggle()
    }
    
    @objc private func deletePictureButtonDidTap() {
        setPopUpViewController(popUp: popUpForPicturesDeletion)
        popUpForPicturesDeletion.titleLabel.text = "\(seletedPictures.value.count)장의 사진을 삭제하시겠어요?"
        popUpForPicturesDeletion.descriptionLabel.text = "삭제를 누르시면 앨범에서\n영구 삭제가 됩니다."
        popUpForPicturesDeletion.setDeleteButton()
        self.present(popUpForPicturesDeletion, animated: true, completion: nil)
        
        Mixpanel.mainInstance().track(event: "selectPhoto/btn/delete")
    }
    @objc func menuButtonDidTap() {
        Mixpanel.mainInstance().track(event: "viewAlbum/btn/setting")
    }
    @objc func cameraButtonDidTap() {
        self.navigationController?.pushViewController(cameraViewcontroller, animated: true)
        
        Mixpanel.mainInstance().track(event: "selectPhoto/btn/addPhoto")
    }
    @objc func deletePictureCancleButtonDidTap() {
        Mixpanel.mainInstance().track(event: "selectPhoto/deletePhotoModal/btn/cancle")
    }
    @objc func deletePictureCompleteButtonDidTap() {
        Mixpanel.mainInstance().track(event: "selectPhoto/deletePhotoModal/btn/complete")
    }
    @objc func renameAlbumCancleButtonDidTap() {
        Mixpanel.mainInstance().track(event: "viewAlbum/editModal/btn/cancel")
    }
    @objc func renameAlbumCompleteButtonDidTap() {
        Mixpanel.mainInstance().track(event: "viewAlbum/editModal/btn/complete")
    }
    @objc func deleteAlbumCancleButtonDidTap() {
        Mixpanel.mainInstance().track(event: "viewAlbum/deleteModal/btn/cancel")
    }
    @objc func deleteAlbumCompleteButtonDidTap() {
        Mixpanel.mainInstance().track(event: "viewAlbum/deleteModal/btn/delete")
    }
    
}

// MARK: - View Layout

extension GridAlbumViewController {
    private func setupViewHierarchy() {
        view.addSubviews(bodyPartSegmentControl, gridAlbumCollectionView, emptyView)
    }
    
    private func setupConstraint() {
        bodyPartSegmentControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(22)
            $0.height.equalTo(56)
            $0.width.equalTo(152)
        }
        gridAlbumCollectionView.snp.makeConstraints {
            $0.top.equalTo(bodyPartSegmentControl.snp.bottom)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        emptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(270 * Constant.Size.screenWidth / Constant.Size.figmaWidth)
            $0.height.equalTo(136 * Constant.Size.screenWidth / Constant.Size.figmaWidth)
        }
    }
}

// MARK: - Extension

extension GridAlbumViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let length =  Constant.Size.screenWidth
            return CGSize(width: (length - 4)/3, height: (length - 4)/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}

extension GridAlbumViewController: UICollectionViewDataSource {
    typealias CameraCell = CameraCollectionViewCell
    typealias TopCell = TopCollectionViewCell
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == gridAlbumCollectionView && editMode ? bodyPartData.count + 1 : bodyPartData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if editMode && indexPath.row == 0 {
                let cell: CameraCell = collectionView.dequeueReusableCell(for: indexPath)
                return cell
            }
            
            let cell: TopCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.selectedViewIsHidden(editMode: editMode)
            let indexPath = editMode ? indexPath.row - 1 : indexPath.row
            cell.setPhotoCell(albumId: albumData.id, bodyPart: "\(bodyPart)", imageName: bodyPartData[indexPath].id, contentMode: gridMode, fileExtension: .png)
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if editMode {
            if indexPath.row == 0 {
                cameraButtonDidTap()
            } else {
                seletedPicturesValue[indexPath.row - 1] = bodyPartData[indexPath.row - 1].id
                seletedPictures.accept(seletedPicturesValue)
            }
        } else {
            let viewController = PanoramaAlbumViewController(pictureInfos: bodyPartData, bodyPart: bodyPart, pictureIndex: indexPath)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == gridAlbumCollectionView && editMode {
            seletedPicturesValue.removeValue(forKey: indexPath.row - 1)
            seletedPictures.accept(seletedPicturesValue)
        }
    }
}

extension GridAlbumViewController: NBSegmentedControlDelegate {
    func changeToIndex(_ segmentControl: NBSegmentedControl, at index: Int) {
        bodyPartIndex = index
        initBodyPartData(index: bodyPartIndex)
        resetDeleteData()
        if !bodyPartData.isEmpty {
            selectedIndexByPart[bodyPartIndex] = selectedIndexByPart[index]
        }
    }
}

extension GridAlbumViewController: PopUpActionProtocol {
    func cancelButtonDidTap(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
        Mixpanel.mainInstance().track(event: "selectPhoto/deletePhotoModal/btn/cancle")
    }
    
    func confirmButtonDidTap(_ button: UIButton, textInfo: String) {
        self.dismiss(animated: true, completion: nil)
        Mixpanel.mainInstance().track(event: "selectPhoto/deletePhotoModal/btn/complete")
    }
}
