//
//  AuthenticationPopupViewController.swift
//  Noonbody
//
//  Created by kong on 2022/08/24.
//

import UIKit

import SnapKit
import Then

class AuthenticationPopupViewController: BaseViewController {
    
    // MARK: - UI Components
    
    private var biometricImage = UIImageView().then {
        $0.image = Asset.Image.faceID.image
    }
    
    private var failedLabel = UILabel().then {
        $0.text = "생체 인증이 취소되었습니다."
        $0.textAlignment = .center
        $0.font = .nbFont(type: .body2Bold)
    }
    
    private var descriptionLabel = UILabel().then {
        $0.text = "서비스를 이용하시려면,\n잠금 해제를 눌러 다시 한 번 시도해주세요."
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.font = .nbFont(type: .caption1)
        $0.textColor = Asset.Color.gray60.color
    }
    
    private lazy var confirmButton = NBPrimaryButton().then {
        $0.setTitle("잠금 해제", for: .normal)
        $0.makeRounded(radius: 28)
        $0.isEnabled = true
        $0.addTarget(self, action: #selector(confirmButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - Properties
    
    var delegate: PopUpActionProtocol?

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        setupConstraints()
    }
    
    // MARK: - Methods
    
    private func setupViewHierarchy() {
        view.addSubviews(biometricImage, failedLabel, descriptionLabel, confirmButton)
    }
    
    private func setupConstraints() {
        biometricImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(failedLabel.snp.top).offset(-20)
        }
        
        failedLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(descriptionLabel.snp.top).offset(-4)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        confirmButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
            $0.height.equalTo(56)
        }
    }
    
    @objc func confirmButtonDidTap() {
        delegate?.cancelButtonDidTap(confirmButton)
    }
}
