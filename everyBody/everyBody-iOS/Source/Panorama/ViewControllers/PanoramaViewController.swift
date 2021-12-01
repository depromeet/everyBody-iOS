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
        
    }
    
    var stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 22
        $0.distribution = .fill
        $0.backgroundColor = .white
    }
    
    // MARK: - Properties
    
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
    
    override func viewDidLoad() {
        initNavigationBar()
        setupViewHierarchy()
        setupCollectionView()
        setupConstraint()
        initSegementData()
        initSegmentedControl()
        render()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initBottomCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        topCollectionView.reloadData()
        bottomCollectionView.reloadData()
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
        bodyPartSegmentControl.delegate = self
    }
    
    private func initSegementData() {
        let bodyPartsArray = ["전신", "상체", "하체"]
        for (index, title) in bodyPartsArray.enumerated() {
            bodyPartSegmentControl.setTitle(at: index, title: title)
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
        let popUp = PopUpViewController(type: .delete)
        popUp.modalTransitionStyle = .crossDissolve
        popUp.modalPresentationStyle = .overCurrentContext
        popUp.delegate = self
        popUp.titleLabel.text = "장의 사진을 삭제하시겠어요?"
        popUp.descriptionLabel.text = "삭제를 누르시면 앨범에서\n영구 삭제가 됩니다."
        self.present(popUp, animated: true, completion: nil)
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
        view.addSubviews(bodyPartSegmentControl, gridButton, stackView)
        stackView.addArrangedSubviews([topCollectionView, bottomCollectionView])
        
    }
    
    private func setupConstraint() {
        bodyPartSegmentControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(22)
            $0.width.equalTo(152)
            $0.height.equalTo(56)
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
            $0.height.equalTo(Constant.Size.screenWidth * (4.0 / 3.0))
        }
    }
}

// MARK: - Extension

extension PanoramaViewController: NBSegmentedControlDelegate {
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
}

extension PanoramaViewController: PopUpActionProtocol {
    func cancelButtonDidTap(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func confirmButtonDidTap(_ button: UIButton) {
        let deleteData = viewModel.deleteArray
        if !deleteData.isEmpty {
            for index in deleteData {
                viewModel.phothArray.remove(at: index-1)
            }
        }
        
        viewModel.deleteArray = []
        topCollectionView.reloadData()
        bottomCollectionView.reloadData()
        
        self.dismiss(animated: true, completion: nil)
    }
}
