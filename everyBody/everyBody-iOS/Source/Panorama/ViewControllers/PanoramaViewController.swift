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

class PanoramaViewController: UIViewController {
    
    // MARK: - UI Components
    
    var gridButton = UIButton().then {
        $0.setImage(Asset.Image.grid.image, for: .normal)
        $0.setImage(Asset.Image.list.image, for: .selected)
        $0.addTarget(self, action: #selector(switchPanoramaMode), for: .touchUpInside)
    }
    
    var albumView = UIView().then {
        $0.isHidden = false
    }
    var gridView = UIView().then {
        $0.isHidden = true
    }
    
    // MARK: - Properties
    
    var gridMode = false
    var viewModel = PanoramaViewModel()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        setupViewHierarchy()
        setupConstraint()
        setPanoramaView()
    }
    
    // MARK: - Methods
    
    private func initNavigationBar() {
        self.navigationController?.initWithRightBarTwoButtons(navigationItem: self.navigationItem, rightButtonImage: [Asset.Image.share.image, Asset.Image.create.image], action: [#selector(tapEditButton), #selector(tapSaveButton)])
        
        // 나중에 뷰모델에서 가져올 것
        self.title = "Album Title"
    }
    
    private func setPanoramaView() {
        let views = [albumView, gridView]
        for parentView in views {
            let viewController = parentView == albumView ? AlbumViewController() : GridViewController()
            viewController.view.frame = parentView.frame
            parentView.addSubview(viewController.view)
            self.addChild(viewController)
            viewController.didMove(toParent: self)
        }
    }

    // MARK: - Actions
    @objc
    private func tapEditButton() {
        
    }
    
    @objc
    private func tapSaveButton() {
        
    }
    
    @objc
    private func switchPanoramaMode() {
        albumView.isHidden.toggle()
        gridView.isHidden.toggle()
        gridButton.isSelected.toggle()
    }
    
}

// MARK: - View Layout

extension PanoramaViewController {
    
    private func setupViewHierarchy() {
        view.addSubviews(gridButton, gridView, albumView)
    }
    
    private func setupConstraint() {
        gridButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.trailing.equalToSuperview().offset(-22)
            $0.height.width.equalTo(24)
        }
        
        albumView.snp.makeConstraints {
            $0.top.equalTo(gridButton.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        [albumView, gridView].forEach { view in
            view.snp.makeConstraints {
                $0.top.equalTo(gridButton.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        }

    }
    
}
