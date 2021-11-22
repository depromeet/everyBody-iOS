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

class PanoramaViewController: UIViewController, NBSegmentedControlDelegate {
    func changeToIndex(_ segmentControl: NBSegmentedControl, at index: Int) {
        switch index {
            case 0:
            return
            case 1:
            return
            case 2:
            return
            default:
            return
    }
}
    
    // MARK: - UI Components
    
    private var gridButton = UIButton().then {
        $0.setImage(Asset.Image.grid.image, for: .normal)
        $0.setImage(Asset.Image.list.image, for: .selected)
        $0.addTarget(self, action: #selector(gridButtonDidTap), for: .touchUpInside)
    }
    
    private let bodyParts = NBSegmentedControl(buttonStyle: .basic, numOfButton: 3).then {
        $0.spacing = 10
    }
    
    var topCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        $0.register(TopCollectionViewCell.self)
        $0.register(CameraCollectionViewCell.self)
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
        $0.bounces = false
        $0.isScrollEnabled = false
        $0.cellForItem(at: IndexPath(row: 0, section: 0))?.isSelected = true
    }
    
    var bottomCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        $0.bounces = false
        $0.register(BottomCollectionViewCell.self)
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
        $0.collectionViewLayout = layout
        $0.cellForItem(at: IndexPath(row: 0, section: 0))?.isSelected = true
    }
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag()
    var viewModel = PanoramaViewModel()
    
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
                topCollectionView.cellForItem(at: tagSelectedIdx)?.isSelected = true
                bottomCollectionView.cellForItem(at: tagSelectedIdx)?.isSelected = true
            }
        }
    }
    
    var editMode = false {
        didSet {
            topCollectionView.reloadData()
            topCollectionView.allowsMultipleSelection = editMode
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
    
    override func viewDidLoad() {
        initNavigationBar()
        setupViewHierarchy()
        setupCollectionView()
        setupConstraint()
        initSegementData()
        initSegmentedControl()
    }
    
    // MARK: - Methods
    
    private func initNavigationBar() {
        navigationController?.initNavigationBar(navigationItem: self.navigationItem,
                                                rightButtonImages: [Asset.Image.share.image,
                                                                    Asset.Image.create.image],
                                                rightActions: [#selector(tapSaveButton),
                                                               #selector(tapEditOrCloseButton)])
        navigationItem.leftBarButtonItems = nil
        title = viewModel.albumTitle
    }
    
    private func initEditNavigationBar() {
        navigationController?.initNavigationBar(navigationItem: self.navigationItem,
                                                leftButtonImages: [Asset.Image.clear.image],
                                                rightButtonImages: [Asset.Image.del.image],
                                                leftActions: [#selector(tapEditOrCloseButton)],
                                                rightActions: [#selector(tapDeleteButton)])
        self.title = "\(viewModel.phothArray.count)장"
    }
    
    private func initSegmentedControl() {
        bodyParts.delegate = self
    }
    
    private func initSegementData() {
        let bodyPartsArray = ["전신", "상체", "하체"]
            for (index, title) in bodyPartsArray.enumerated() {
                bodyParts.setTitle(at: index, title: title)
        }
    }
    
    private func switchPanoramaMode() {
        if gridMode || editMode {
            topCollectionView.setCollectionViewLayout(verticalFlowLayout, animated: false)
            topCollectionView.snp.remakeConstraints {
                $0.top.equalTo(bodyParts.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
            }

            bottomCollectionView.snp.remakeConstraints {
                $0.top.equalTo(topCollectionView.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
                $0.height.equalTo(0)
            }
        } else {
            topCollectionView.setCollectionViewLayout(horizontalFlowLayout, animated: false)
            topCollectionView.snp.remakeConstraints {
                $0.top.equalTo(bodyParts.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(Constant.Size.screenWidth * (4.0 / 3.0))
            }
            
            bottomCollectionView.snp.remakeConstraints {
                $0.top.equalTo(topCollectionView.snp.bottom).offset(20)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(22)
            }
        }
        topCollectionView.reloadData()
        self.view.layoutIfNeeded()
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
        /// edit 내비에서 deleteButton 눌렀을 때 처리
    }
    
    @objc
    private func gridButtonDidTap() {
        gridButton.isSelected.toggle()
        gridMode.toggle()
        switchPanoramaMode()
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
        view.addSubviews(bodyParts, gridButton, topCollectionView, bottomCollectionView)
    }
    
    private func setupConstraint() {
        bodyParts.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }
        
        gridButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.trailing.equalToSuperview().offset(-22)
            $0.height.width.equalTo(24)
            $0.centerY.equalTo(bodyParts)
        }
        
        topCollectionView.snp.makeConstraints {
            $0.top.equalTo(bodyParts.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constant.Size.screenWidth * (4.0 / 3.0))
        }
        
        bottomCollectionView.snp.makeConstraints {
            $0.top.equalTo(topCollectionView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(22)
        }
    }
}
