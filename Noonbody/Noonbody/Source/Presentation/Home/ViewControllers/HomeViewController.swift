//
//  HomeViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/13.
//

import UIKit

import SnapKit
import Then
import RxCocoa
import RxSwift
import SkeletonView
import Mixpanel

class HomeViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private lazy var cameraButton = UIButton().then {
        $0.backgroundColor = Asset.Color.Primary.main.color
        $0.setImage(Asset.Image.photoCamera.image, for: .normal)
        $0.makeRounded(radius: 28)
        $0.addTarget(self, action: #selector(pushToCameraViewController), for: .touchUpInside)
    }
    
    private lazy var nicknameLabel = UILabel().then {
        $0.text = "오늘도 화이팅!"
        $0.font = .nbFont(type: .subtitle)
    }
    
    private lazy var mottoLabel = UILabel().then {
        $0.text = UserManager.motto
        $0.font = .nbFont(type: .subtitle)
    }
    
    private var emptyView = AlbumEmptyView(type: .album).then {
        $0.isHidden = true
        $0.button.addTarget(self, action: #selector(albumCreationButtonDidTap), for: .touchUpInside)
    }
    
    private lazy var albumCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 32
        layout.minimumInteritemSpacing = 11
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        layout.itemSize = CGSize(width: (Constant.Size.screenWidth - 51) / 2, height: 211)
        $0.register(AlbumCollectionViewCell.self)
        $0.register(ListCollectionViewCell.self)
        $0.registerReusableView(FeedbackCollectionReusableView.self,
                                kind: UICollectionView.elementKindSectionFooter)
        $0.backgroundColor = .clear
        $0.collectionViewLayout = layout
        $0.isSkeletonable = true
    }
    
    // MARK: - Properties
    
    private let viewModel = AlbumViewModel(albumUseCase: DefaultFetchAlbumsUseCase(repository: LocalAlbumRepositry()),
                                           feedbackUseCase: DefaultSendFeedbackUseCase(sendFeedbackRepository: DefaultSendFeedbackRepository()))
    
    private var albumData: [Album] = [] {
        didSet {
            albumCollectionView.reloadData()
        }
    }
    
    private var isGrid: Bool = true {
        didSet {
            albumCollectionView.reloadData()
        }
    }
    
    private let feedbackPopUp = FeedbackPopUpViewController()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupCollectionView()
        initListNavigationBar()
        setupViewHierarchy()
        setupConstraint()
        navigationController?.isNavigationBarHidden = false
        
    }
    
    // MARK: - Methods
    
    func bind() {
        let input = AlbumViewModel.Input(viewWillAppear: rx.viewWillAppear.map { _ in },
                                         content: feedbackPopUp.textField.rx.text.orEmpty.asObservable(),
                                         starRate: feedbackPopUp.starRate.asObservable(),
                                         sendButtonControlEvent: feedbackPopUp.sendButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.album
            .drive(onNext: { [weak self] data in
                guard let self = self else { return }
                self.albumData = data
                self.emptyView.isHidden = self.albumData.count != 0 ? true : false
            })
            .disposed(by: disposeBag)
        
        UserDefaults.standard.rx
            .observe(String.self, Constant.UserDefault.motto)
            .subscribe(onNext: { (value) in
                if let value = value {
                    self.mottoLabel.text = value
                }
            })
            .disposed(by: disposeBag)
        
        output.canSend
            .drive(feedbackPopUp.sendButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.sendFeedbackStatusCode
            .drive(onNext: { [weak self] statusCode in
                guard let self = self else { return }
                if statusCode == 200 {
                    self.dismiss(animated: true, completion: nil)
                    self.showToast(type: .send)
                    self.resetFeedback()
                }
            }).disposed(by: disposeBag)
    }
    
    private func initNavigationBar() {
        navigationController?.initNavigationBar(
            navigationItem: navigationItem,
            rightButtonImages: [Asset.Image.add.image,
                                Asset.Image.grid.image],
            rightActions: [#selector(pushToFolderCreationView),
                           #selector(switchAlbumMode)]
        )

    }
    
    private func initListNavigationBar() {
        navigationController?.initNavigationBar(
            navigationItem: navigationItem,
            rightButtonImages: [Asset.Image.add.image,
                                Asset.Image.list.image],
            rightActions: [#selector(pushToFolderCreationView),
                           #selector(switchAlbumMode)]
        )
        
        makeProfileImage()
    }
    
    private func resetFeedback() {
        feedbackPopUp.textField.text = ""
        feedbackPopUp.starRate.onNext(0)
        feedbackPopUp.rateButtonList.forEach { button in
            button.isSelected = false
        }
    }
    
    private func makeProfileImage() {
        let button = UIButton(type: .system)
        button.imageView?.image = Asset.Image.profileImg.image
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setBackgroundImage(Asset.Image.profileImg.image, for: .normal)
        button.addTarget(self, action: #selector(pushToPreferenceViewController), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    private func setupCollectionView() {
        albumCollectionView.dataSource = self
        albumCollectionView.delegate = self
    }
    
    private func setupViewHierarchy() {
        view.addSubviews(mottoLabel, albumCollectionView, cameraButton, emptyView)
    }
    
    // MARK: - Actions
    
    @objc
    private func switchAlbumMode() {
        isGrid.toggle()
        let layout = UICollectionViewFlowLayout()
        if isGrid {
            layout.minimumLineSpacing = 32
            layout.minimumInteritemSpacing = 11
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
            layout.itemSize = CGSize(width: (Constant.Size.screenWidth - 51) / 2, height: 211)
            albumCollectionView.setCollectionViewLayout(layout, animated: true)
            initListNavigationBar()
        } else {
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
            layout.itemSize = CGSize(width: (Constant.Size.screenWidth - 40), height: 446)
            albumCollectionView.setCollectionViewLayout(layout, animated: true)
            albumCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            initNavigationBar()
        }
    }
    
    @objc
    private func pushToFolderCreationView() {
        let viewController = AlbumCreationViewController()
        Mixpanel.mainInstance().track(event: "main/btn/addAlbum")
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    private func pushToCameraViewController() {
        let viewController = CameraViewController()
        Mixpanel.mainInstance().track(event: "main/btn/shot")
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    private func pushToPreferenceViewController() {
        let viewController = ProfileViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func albumCreationButtonDidTap() {
        let viewController = AlbumCreationViewController()
        Mixpanel.mainInstance().track(event: "main/btn/settingProfile")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

// MARK: - Layout

// MARK: - Extension

extension HomeViewController {
    private func setupConstraint() {
        cameraButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.width.height.equalTo(56)
        }
        
        mottoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalTo(20)
        }
        
        albumCollectionView.snp.makeConstraints {
            $0.top.equalTo(mottoLabel.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        emptyView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(270 * Constant.Size.screenWidth / Constant.Size.figmaWidth)
            $0.height.equalTo(136 * Constant.Size.screenWidth / Constant.Size.figmaWidth)
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = GridAlbumViewController(albumId: albumData[indexPath.row].id, albumData: albumData[indexPath.row])
        Mixpanel.mainInstance().track(event: "main/album")
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableView(FeedbackCollectionReusableView.self,
                                                        indexPath: indexPath,
                                                        kind: UICollectionView.elementKindSectionFooter)
        footer.delegate = self
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return AlbumCollectionViewCell.className
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isGrid {
            let cell: AlbumCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
            cell.style = .album
            cell.setData(album: albumData[indexPath.row])
            return cell
        }
        let cell: ListCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.setData(album: albumData[indexPath.row])
        return cell
    }
    
}

extension HomeViewController: PopUpActionProtocol {
    func cancelButtonDidTap(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
        resetFeedback()
    }
}

extension HomeViewController: footerDelegate {
    func feedbackButtonDidTap() {
        feedbackPopUp.modalTransitionStyle = .crossDissolve
        feedbackPopUp.modalPresentationStyle = .overCurrentContext
        feedbackPopUp.delegate = self
        Mixpanel.mainInstance().track(event: "main/bn/feedBack")
        self.present(feedbackPopUp, animated: true, completion: nil)
    }
}
