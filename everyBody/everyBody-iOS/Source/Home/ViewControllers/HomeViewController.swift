//
//  HomeViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/13.
//

import UIKit

class HomeViewController: BaseViewController {

    private lazy var albumButton = UIButton().then {
        $0.backgroundColor = Asset.Color.keyPurple.color
        $0.setImage(Asset.Image.photoCamera.image, for: .normal)
        $0.makeRounded(radius: 28)
        $0.addTarget(self, action: #selector(pushToCameraViewController), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavigationBar()
        setupContraint()
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
    
    @objc
    private func switchAlbumMode() {
        let viewController = PanoramaViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    private func pushToFolderCreationView() {
        let viewController = FolderCreationViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    private func pushToCameraViewController() {
        let viewController = CameraViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc
    private func pushToPreferenceViewController() {
        let viewController = PreferenceViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension HomeViewController {
    
    private func setupContraint() {
        view.addSubview(albumButton)
        
        albumButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            $0.width.height.equalTo(56)
        }
    }
    
}
