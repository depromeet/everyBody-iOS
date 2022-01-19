//
//  ProfileViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import UIKit

import RxCocoa
import RxSwift

class ProfileViewController: BaseViewController {

    // MARK: - UI Components
    
    private let profileImageView = UIImageView().then {
        $0.makeRounded(radius: 44)
        $0.backgroundColor = Asset.Color.gray10.color
    }
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
    private lazy var arrayOfCells: [ProfileTableViewCell] = [] {
        didSet {
            if arrayOfCells.count == 4 {
                bindCellTextfield()
            }
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setupNavigationBar()
        setupTableViewDelegate()
        setupConstraint()
    }
    
    // MARK: - Methods
    
    func setupNavigationBar() {
        navigationController?.initNaviBarWithBackButton()
        navigationItem.rightBarButtonItem = completeBarButtonItem
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
        
        output.profileImage
            .drive(onNext: { [weak self] imageURL in
                guard let self = self else { return }
                self.profileImageView.setImage(with: imageURL)
            })
            .disposed(by: disposeBag)
    }
    
    func bindCellTextfield() {
        let input = ProfileViewModel.CellInput(nickNameTextField: arrayOfCells[0].profileTextField.rx.text.orEmpty.asObservable(),
                                               mottoTextfield: arrayOfCells[1].profileTextField.rx.text.orEmpty.asObservable(),
                                               completeButtonTap: completeBarButtonItem.rx.tap)
        let output = viewModel.transformCellData(input: input)
        
        output.canSave
            .drive(completeBarButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.statusCode
            .drive(onNext: { [weak self] statusCode in
                guard let self = self else { return }
                if statusCode == 200 {
                    self.showToast(type: .save)
                }
            }).disposed(by: disposeBag)
    }
    
    @objc
    private func pushToNotificationSetting() {
        let viewController = NotificationViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if cellData[indexPath.item] == .saved {
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
        
        switch cellData[indexPath.item] {
        case .nickName(let nickname):
            cell.type = .textField
            cell.setData(title: cellData[indexPath.item].title, placeholder: "닉네임을 입력해주세요")
            cell.setTextField(text: nickname)
        case .motto(let motto):
            cell.type = .textField
            cell.setData(title: cellData[indexPath.item].title, placeholder: "천천히 그리고 꾸준히!")
            cell.setTextField(text: motto)
        case .pushNotification:
            cell.type = .right
            cell.setData(title: cellData[indexPath.item].title)
            cell.setRightButtonEvent(target: self, action: #selector(pushToNotificationSetting))
            cell.setRightButtonImage(image: Asset.Image.backwardsBack.image)
        case .saved:
            cell.type = .appSwitch
            cell.setupConstraint()
            cell.setData(title: cellData[indexPath.item].title)
            cell.descriptionLabel.text = "눈바디 앱에서 촬영한 사진을 앱에만 저장합니다."
            cell.saveOnlyInAppSwitch.isOn = !UserManager.saveBulitInInLibrary
        }
        
        arrayOfCells.append(cell)
        return cell
    }
    
}

// MARK: - Layout

extension ProfileViewController {
    
    func setupConstraint() {
        view.addSubviews(profileImageView, tableView)
        
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(32)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(88)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(58)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
}
