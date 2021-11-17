//
//  FolderSelectionViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/07.
//

import UIKit

import RxCocoa
import RxSwift

class FolderSelectionViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 32
        layout.sectionInset = UIEdgeInsets(top: 17, left: 20, bottom: 0, right: 20)
        layout.itemSize = CGSize(width: (Constant.Size.screenWidth - 51) / 2, height: 211)
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
        $0.collectionViewLayout = layout
        $0.register(FolderCollectionViewCell.self)
    }
    
    // MARK: - Properties
    
    var viewModel = AlbumViewModel()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        render()
        setupViewHierarchy()
        setupConstraint()
        bind()
    }
    
    // MARK: - Methods
    
    func render() {
        title = "폴더 선택"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(completeButtonDidTap))
    }
    
    func bind() {
        viewModel.albumDummy
            .bind(to: collectionView.rx.items(cellIdentifier: FolderCollectionViewCell.className,
                                              cellType: FolderCollectionViewCell.self)) { row, element, cell in
                if row != 0 {
                    cell.setData(album: element)
                } else {
                    cell.setFirstCell()
                }
            }
            .disposed(by: disposeBag)
        
        collectionView.rx
            .itemSelected
            .subscribe(onNext: { indexPath in
                if indexPath.row == 0 {
                    let popUp = PopUpViewController(type: .textField)
                    popUp.modalTransitionStyle = .crossDissolve
                    popUp.modalPresentationStyle = .overCurrentContext
                    popUp.delegate = self
                    popUp.titleLabel.text = "폴더명을 입력해주세요."
                    self.present(popUp, animated: true, completion: nil)
                }
            }).disposed(by: disposeBag)
    }
    
    @objc
    func completeButtonDidTap() {
        // TODO: - Save Picture API
    }
}

extension FolderSelectionViewController: PopUpActionProtocol {
    
    func cancelButtonDidTap(_ button: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func confirmButtonDidTap(_ button: UIButton, textInfo: String) {
        // TODO: - Create Album API
    }
    
}

// MARK: - Layout

extension FolderSelectionViewController {
    
    func setupViewHierarchy() {
        view.addSubview(collectionView)
    }
    
    func setupConstraint() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
