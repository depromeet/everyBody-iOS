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
    
    private lazy var nicknameLabel = UILabel().then {
        $0.text = UserDefaults.standard.string(forKey: "nickname") ?? ""
        $0.font = .nbFont(type: .subtitle)
    }
    
    private lazy var mottoLabel = UILabel().then {
        $0.text = UserDefaults.standard.string(forKey: "motto") ?? ""
        $0.font = .nbFont(type: .body3)
        $0.textColor = Asset.Color.gray60.color
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
        $0.backgroundColor = .white
        $0.collectionViewLayout = layout
    }
    
    // MARK: - Properties
    
    private let viewModel = AlbumViewModel(albumUseCase: DefaultAlbumUseCase(albumRepository: DefaultAlbumRepositry()))
    
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
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        initListNavigationBar()
        setupCollectionView()
        setupViewHierarchy()
        setupConstraint()
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Methods
    
    func bind() {
        let input = AlbumViewModel.Input(viewWillAppear: rx.viewWillAppear.map { _ in })
        let output = viewModel.transform(input: input)
        
        output.album
            .drive(onNext: { [weak self] data in
                guard let self = self else { return }
                self.albumData = data
                self.emptyView.isHidden = self.albumData.count != 0 ? true : false
            })
            .disposed(by: disposeBag)
        
        UserDefaults.standard.rx
            .observe(String.self, "nickname")
            .subscribe(onNext: { (value) in
                if let value = value {
                    self.nicknameLabel.text = value
                }
            })
            .disposed(by: disposeBag)
        
        UserDefaults.standard.rx
            .observe(String.self, "motto")
            .subscribe(onNext: { (value) in
                if let value = value {
                    self.mottoLabel.text = value
                }
            })
            .disposed(by: disposeBag)
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
    
    private func makeProfileImage() {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(pushToPreferenceViewController), for: .touchUpInside)
        
        let imageData = try? Data(contentsOf: URL(string: UserDefaults.standard.string(forKey: "profile") ?? "")!)
        
        if let imageData = imageData, let image =  UIImage(data: imageData)?.resizeImage(to: button.frame.size) {
            button.setBackgroundImage(image, for: .normal)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    private func setupCollectionView() {
        albumCollectionView.dataSource = self
        albumCollectionView.delegate = self
    }
    
    private func setupViewHierarchy() {
        view.addSubviews(nicknameLabel, mottoLabel, albumCollectionView, cameraButton, emptyView)
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
    
    @objc func albumCreationButtonDidTap() {
        let viewController = AlbumCreationViewController()
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
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = PanoramaViewController(albumId: albumData[indexPath.row].id, albumData: albumData[indexPath.row])
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension HomeViewController: UICollectionViewDataSource {
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