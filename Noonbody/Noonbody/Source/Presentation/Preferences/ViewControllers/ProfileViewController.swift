//
//  ProfileViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import UIKit

import RxCocoa
import RxSwift
import Mixpanel

class ProfileViewController: BaseViewController {

    // MARK: - UI Components
    
    private let tableView = UITableView().then {
        $0.register(ProfileTableViewCell.self)
        $0.separatorStyle = .none
        $0.bounces = false
    }
    private let completeBarButtonItem = UIBarButtonItem(title: "완료",
                                                 style: .plain,
                                                 target: self,
                                                 action: nil)
    
    // MARK: - Properties
    
    // TODO: - Coordinator로 변경 할 때 의존성 주입 컨테이너 생성
    private let viewModel = ProfileViewModel(profileUseCase: DefaultProfileUseCase(
                                             preferenceRepository: DefaultPreferenceRepository()))
    private lazy var cellData: [ProfileDataType] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private lazy var arrayOfCells: [ProfileTableViewCell] = []
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setupNavigationBar()
        setupTableViewDelegate()
        setupConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isPushed = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !isPushed {
            Mixpanel.mainInstance().track(event: "setting/btn/back")
        }
    }
    
    
    // MARK: - Methods
    
    func setupNavigationBar() {
        navigationController?.initNaviBarWithBackButton()
        title = "프로필 설정"
    }
    
    func setupTableViewDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func bind() {
        let input = ProfileViewModel.Input(viewWillAppear: rx.viewWillAppear.map { _ in })
        let output = viewModel.transform(input: input)
        
        output.cellData
            .drive(onNext: { [weak self] data in
                guard let self = self else { return }
                self.cellData = data
            })
            .disposed(by: disposeBag)
    }
    
    @objc
    private func pushToMottoViewController() {
        let viewController = MottoViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
        Mixpanel.mainInstance().track(event: "setting/sentence")
    }
    
    @objc
    private func pushToNotificationSetting() {
        let viewController = NotificationViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
        Mixpanel.mainInstance().track(event: "setting/alarm")
    }
    
    @objc
    private func pushToPrivacyPolicyViewController() {
        let viewController = PrivacyPolicyViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isAppSwitch = [.saved, .hideThumbnail, .biometricAuthentication]
                        .contains(cellData[indexPath.item])
        if isAppSwitch {
            return 80
        }
        return 50
    }
    
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ProfileTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let title = cellData[indexPath.item].title
        switch cellData[indexPath.item] {
        case .motto(let motto):
            cell.type = .textLabel
            cell.setData(title: title)
            cell.setTextLabel(text: motto)
            cell.setRightButtonEvent(target: self, action: #selector(pushToMottoViewController))
            cell.setRightButtonImage(image: Asset.Image.backwardsBack.image)
//        case .pushNotification:
//            cell.type = .right
//            cell.setData(title: title)
//            cell.setRightButtonEvent(target: self, action: #selector(pushToNotificationSetting))
//            cell.setRightButtonImage(image: Asset.Image.backwardsBack.image)
        case .saved:
            cell.type = .appSwitch
            cell.dataType = .saved
            cell.setupConstraint()
            cell.setData(title: title)
            cell.descriptionLabel.text = "눈바디 앱에서 촬영한 사진을 앱에만 저장합니다."
            cell.switchButton.isOn = !UserManager.saveBulitInInLibrary
        case .hideThumbnail:
            cell.type = .appSwitch
            cell.dataType = .hideThumbnail
            cell.setupConstraint()
            cell.setData(title: title)
            cell.descriptionLabel.text = "앨범 썸네일을 기본 이미지로 가릴 수 있습니다."
            cell.switchButton.isOn = UserManager.hideThumbnail
        case .biometricAuthentication:
            cell.type = .appSwitch
            cell.dataType = .biometricAuthentication
            cell.setupConstraint()
            cell.setData(title: title)
            cell.descriptionLabel.text = "Face ID, Touch ID를 등록해 앱 잠금을 할 수 있습니다."
            cell.switchButton.isOn = UserManager.biometricAuthentication
        case .privacyPolicy:
            cell.type = .right
            cell.setData(title: title)
            cell.setRightButtonEvent(target: self, action: #selector(pushToPrivacyPolicyViewController))
            cell.setRightButtonImage(image: Asset.Image.backwardsBack.image)
        }
        arrayOfCells.append(cell)
        return cell
    }
}

// MARK: - Layout

extension ProfileViewController {
    
    func setupConstraint() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
}
