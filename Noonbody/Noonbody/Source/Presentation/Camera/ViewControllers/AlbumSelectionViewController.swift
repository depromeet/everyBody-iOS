//
//  AlbumSelectionViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/07.
//

import UIKit

import RxCocoa
import RxSwift
import Lottie

class AlbumSelectionViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 32
        layout.sectionInset = UIEdgeInsets(top: 17, left: 20, bottom: 0, right: 20)
        layout.itemSize = CGSize(width: (Constant.Size.screenWidth - 51) / 2, height: 211)
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
        $0.collectionViewLayout = layout
        $0.register(AlbumCollectionViewCell.self)
    }
    
    private let completeBarButtonItem = UIBarButtonItem(title: "완료",
                                                        style: .plain,
                                                        target: self,
                                                        action: nil)
    
    private let popUp = PopUpViewController(type: .textField)
    private let loadingView = AnimationView(name: "loading").then {
        $0.loopMode = .loop
    }
    private let backgroundView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.3)
    }
    
    // MARK: - Properties
    
    private let viewModel = AlbumSelectionViewModel(albumUseCase: DefaultAlbumUseCase(albumRepository: DefaultAlbumRepositry()))
    private lazy var albumData: [Album] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    private let requestManager = CameraRequestManager.shared
    private var albumRequest = PublishSubject<PhotoRequestModel>()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        render()
        setDelegation()
        setupViewHierarchy()
        setupConstraint()
        bind()
    }
    
    // MARK: - Methods
    
    override func render() {
        title = "폴더 선택"
        
        navigationItem.rightBarButtonItem = completeBarButtonItem
    }
    
    func setDelegation() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func bind() {
        let input = AlbumSelectionViewModel.Input(viewWillAppear: rx.viewWillAppear.map { _ in },
                                                  saveButtonControlEvent: completeBarButtonItem.rx.tap,
                                                  albumSelection: collectionView.rx.itemSelected.asDriver(),
                                                  photoRequestModel: albumRequest)
        let output = viewModel.transform(input: input)
        
        output.album
            .drive(onNext: { [weak self] data in
                guard let self = self else { return }
                self.albumData = data
            })
            .disposed(by: disposeBag)
        
        output.statusCode
            .drive(onNext: { [weak self] statusCode in
                guard let self = self else { return }
                if statusCode == 200 {
                    self.showToast(type: .save)
                    self.popViewController()
                }
                // TODO: - 서버에게 에러 코드 물어봐서 에러에 맞게 토스트 띄우기
            })
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(onNext: { [weak self] isLoading in
                guard let self = self else { return }
                isLoading ? self.setLoadingView() : self.removeLoadingView()
            })
            .disposed(by: disposeBag)
        
        let popUpInput = AlbumSelectionViewModel.PopUpInput(albumNameTextField: popUp.textField.rx.text.orEmpty.asObservable(),
                                                            creationControlEvent: popUp.confirmButton.rx.tap)
        let popUpOutput = viewModel.albumCreationDidTap(input: popUpInput)
        
        popUpOutput.album
            .drive(onNext: { [weak self] data in
                guard let self = self else { return }
                if let data = data {
                    self.albumData.append(data)
                }
                self.showToast(type: .album)
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func popViewController() {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: CameraViewController.self) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.popToViewController(controller, animated: true)
                }
                break
            }
        }
    }
    
    private func setLoadingView() {
        self.completeBarButtonItem.isEnabled = false
        self.loadingView.isHidden = false
        self.loadingView.play()
        self.backgroundView.isHidden = false
    }
    
    private func removeLoadingView() {
        self.completeBarButtonItem.isEnabled = true
        self.loadingView.isHidden = true
        self.backgroundView.isHidden = true
    }
}

extension AlbumSelectionViewController: PopUpActionProtocol {
    
    func cancelButtonDidTap(_ button: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func confirmButtonDidTap(_ button: UIButton, textInfo: String) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UICollectionViewDelegate

extension AlbumSelectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            popUp.modalTransitionStyle = .crossDissolve
            popUp.modalPresentationStyle = .overCurrentContext
            popUp.delegate = self
            popUp.titleLabel.text = "폴더명을 입력해주세요."
            self.present(popUp, animated: true, completion: nil)
        } else {
            requestManager.albumId = albumData[indexPath.row - 1].id
            albumRequest.onNext(requestManager.toPhotoRequestModel())
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension AlbumSelectionViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumData.count + 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AlbumCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        if indexPath.row != 0 {
            cell.style = .folder
            cell.setNoFirstCell()
            cell.setData(album: albumData[indexPath.row - 1])
        } else {
            cell.setFirstCell()
        }
        return cell
    }
    
}

// MARK: - Layout

extension AlbumSelectionViewController {
    
    func setupViewHierarchy() {
        view.addSubviews(collectionView, backgroundView, loadingView)
    }
    
    func setupConstraint() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        backgroundView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
}
