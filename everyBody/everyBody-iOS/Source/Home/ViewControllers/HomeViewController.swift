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

class HomeViewController: BaseViewController {
    
    // MARK: - UI Components

    private lazy var cameraButton = UIButton().then {
        $0.backgroundColor = Asset.Color.keyPurple.color
        $0.setImage(Asset.Image.photoCamera.image, for: .normal)
        $0.makeRounded(radius: 28)
        $0.addTarget(self, action: #selector(pushToCameraViewController), for: .touchUpInside)
    }
    
    private lazy var emptyView = UIView()
    
    private lazy var nicknameLabel = UILabel().then {
        $0.text = "예꽁이"
        $0.font = .nbFont(type: .subtitle)
    }
    
    private lazy var mottoLabel = UILabel().then {
        $0.text = "난 퀸이될거야."
        $0.font = .nbFont(type: .body3)
        $0.textColor = Asset.Color.gray60.color
    }
    
    private lazy var emptyDescription = UILabel().then {
        $0.text = "앨범이 없습니다.\n지금 앨범을 만들어 기록해보세요."
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .nbFont(type: .body2)
        $0.textColor = Asset.Color.gray50.color
    }
    
    private var createButton = UIButton().then {
        $0.setTitle("앨범 생성", for: .normal)
        $0.backgroundColor = Asset.Color.gray50.color
        $0.makeRounded(radius: 28)
    }
    
    private lazy var albumCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 32
        layout.minimumInteritemSpacing = 11
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.itemSize = CGSize(width: (Constant.Size.screenWidth - 51) / 2, height: 211)
        $0.register(AlbumCollectionViewCell.self)
        $0.backgroundColor = .white
        $0.collectionViewLayout = layout
    }
    
    // MARK: - Properties
    
    private let viewModel = AlbumViewModel(albumUseCase: DefaultAlbumUseCase(albumRepository: DefaultAlbumRepositry()))
    
    private lazy var albumData: [Album] = [] {
        didSet {
            albumCollectionView.reloadData()
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        initNavigationBar()
        setupCollectionView()
        setupViewHierarchy()
        setupConstraint()

    }
    
    // MARK: - Methods
    
    func bind() {
        let input = AlbumViewModel.Input(viewWillAppear: rx.viewWillAppear.map { _ in })
        let output = viewModel.transeform(input: input)
        
        output.album
            .drive(onNext: { [weak self] data in
                guard let self = self else { return }
                self.albumData = data
            })
            .disposed(by: disposeBag)
    }
    
    private func initNavigationBar() {
        navigationController?.initNavigationBar(
            navigationItem: navigationItem,
            leftButtonImages: [Asset.Image.grid.image],
            rightButtonImages: [Asset.Image.add.image,
                                Asset.Image.grid.image],
            leftActions: [#selector(pushToPreferenceViewController)],
            rightActions: [#selector(pushToFolderCreationView),
                           #selector(switchAlbumMode)]
        )
    }
    
    private func setupCollectionView() {
        albumCollectionView.dataSource = self
    }
    
    private func setupViewHierarchy() {
        view.addSubviews(nicknameLabel, mottoLabel, emptyView, albumCollectionView, cameraButton)
        emptyView.addSubviews(emptyDescription, createButton)
    }

    // MARK: - Actions
    
    @objc
    private func switchAlbumMode() {
        let viewController = PanoramaViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    private func pushToFolderCreationView() {
        let viewController = AlbumCreationViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    private func pushToCameraViewController() {
        let viewController = CameraViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    private func pushToPreferenceViewController() {
        let viewController = ProfileViewController()
        navigationController?.pushViewController(viewController, animated: true)
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
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalTo(20)
        }
        
        mottoLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(4)
            $0.leading.equalTo(nicknameLabel)
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
        
        emptyDescription.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        createButton.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.width.equalTo(121)
            $0.centerX.bottom.equalToSuperview()
        }
    }
}

extension HomeViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AlbumCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.style = .album
        cell.setData(album: albumData[indexPath.row])
//        cell.setData(album: viewModel.dummy[indexPath.row])
        return cell
    }
    
}
