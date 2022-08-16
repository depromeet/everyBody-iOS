//
//  MottoViewController.swift
//  Noonbody
//
//  Created by kong on 2022/08/16.
//

import UIKit

import RxSwift
import Then
import SnapKit

final class MottoViewController: BaseViewController {
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.text = "좌우명 수정"
        $0.font = .nbFont(type: .body3)
        $0.textColor = Asset.Color.gray80.color
    }
    
    private let mottoTextField = UITextField().then {
        $0.text = UserManager.motto
        $0.font = .nbFont(type: .body3)
        $0.textColor = Asset.Color.gray80.color
        $0.addLeftPadding()
        $0.makeRoundedWithBorder(radius: 4,
                                 color: Asset.Color.gray80.color.cgColor,
                                 borderWith: 1)
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        setupViewHierarchy()
        setupConstraints()
        setupNavigationBar()
        bindCellTextfield()
    }

    // MARK: - Method
    
    private func setupNavigationBar() {
        title = "좌우명 수정"
    }
    
    private func setupViewHierarchy() {
        view.addSubviews(titleLabel, mottoTextField)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        mottoTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
    }
        
    func bindCellTextfield() {
        mottoTextField.rx.text.orEmpty
            .asObservable()
            .subscribe(onNext: { text in
                UserManager.motto = text
                if text.isEmpty {
                    self.mottoTextField.placeholder = "좌우명을 입력해주세요."
                }
            }).disposed(by: self.disposeBag)
        
    }
}
