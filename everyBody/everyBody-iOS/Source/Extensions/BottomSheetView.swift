//
//  BottomSheetView.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/30.
//

import UIKit

import RxCocoa
import RxSwift

class BottomSheetView: UIView {
    
    var viewModel = PoseViewModel()
    private var disposeBag = DisposeBag()
    var indexPathSubject = PublishSubject<Int>()
    
    private let poseCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 54, height: 72)
        $0.backgroundColor = .white
        $0.contentInset = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 0)
        $0.showsHorizontalScrollIndicator = false
        $0.collectionViewLayout = layout
    }
    let downButton = UIButton().then {
        $0.setImage(Asset.Image.arrowDown.image, for: .normal)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        poseCollectionView.register(PoseCollectionViewCell.self, forCellWithReuseIdentifier: "PoseCollectionViewCell")
        render()
        setLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func render() {
        backgroundColor = .white
    }
    
    private func setLayout() {
        addSubviews(poseCollectionView, downButton)
        
        poseCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(72)
        }
        
        downButton.snp.makeConstraints {
            $0.top.equalTo(poseCollectionView.snp.bottom).offset(36)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(36)
            $0.height.equalTo(36)
        }
    }
    
    private func bind() {
        viewModel.poseSubject
            .bind(to: poseCollectionView.rx.items(cellIdentifier: "PoseCollectionViewCell", cellType: PoseCollectionViewCell.self)) { row, element, cell in
                if row == 0 {
                    cell.backgroundColor = Asset.Color.gray30.color
                } else {
                    cell.setData(image: element.thumnailImage)
                }
            }
            .disposed(by: disposeBag)
        
        poseCollectionView
            .rx
            .itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.indexPathSubject.onNext(indexPath.row)
            }).disposed(by: disposeBag)
    }
    
}