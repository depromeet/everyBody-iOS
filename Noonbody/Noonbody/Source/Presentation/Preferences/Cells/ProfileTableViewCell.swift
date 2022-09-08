//
//  ProfileTableViewCell.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    enum Style {
        case textLabel
        case right
        case appSwitch
    }
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = .nbFont(type: .body2SemiBold)
        $0.textColor = Asset.Color.gray80.color
    }
    public let profileTextLabel = UILabel().then {
        $0.textColor = Asset.Color.gray80.color
    }

    lazy var switchButton = NBSwitch(width: 40, height: 24).then {
        $0.descriptionLabel.isHidden = true
        $0.setOffColor(color: Asset.Color.gray30.color)
        $0.delegate = self
    }
    
    private let separatorLine = UIView().then {
        $0.backgroundColor = Asset.Color.gray20.color
    }
    
    var rightButton: UIButton?
    
    let descriptionLabel = UILabel().then {
        $0.font = .nbFont(type: .caption1)
        $0.textColor = Asset.Color.gray60.color
    }
    
    // MARK: - Properties
    
    var type: Style? {
        didSet {
            setupConstraint()
        }
    }
    
    var dataType: ProfileDataType?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraint() {
        guard let type = type else { return }

        addSubviews(titleLabel, separatorLine)
    
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        separatorLine.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        switch type {
        case .right:
            descriptionLabel.removeFromSuperview()
            switchButton.removeFromSuperview()
            profileTextLabel.removeFromSuperview()
            rightButton = UIButton()
            
            guard let button = rightButton else { return }
            addSubview(button)
            
            button.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(20)
            }
        case .textLabel:
            descriptionLabel.removeFromSuperview()
            switchButton.removeFromSuperview()
            rightButton = UIButton()
            
            guard let button = rightButton else { return }
            addSubviews(button, profileTextLabel)
            
            button.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(24)
                $0.trailing.equalToSuperview().inset(20)
            }
            profileTextLabel.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().offset(113)
                $0.trailing.equalTo(button.snp.leading).offset(-20)
            }
        case .appSwitch:
            rightButton?.removeFromSuperview()
            profileTextLabel.removeFromSuperview()
            addSubviews(descriptionLabel, switchButton)
            
            titleLabel.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(16)
                $0.leading.equalToSuperview().offset(20)
            }
            descriptionLabel.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(11)
                $0.leading.equalTo(titleLabel.snp.leading)
            }
            switchButton.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.top)
                $0.trailing.equalToSuperview().offset(-20)
                $0.width.equalTo(38)
                $0.height.equalTo(24)
            }
        }
    }
    
    func setData(title: String) {
        titleLabel.text = title
    }
    
    func setTextLabel(text: String) {
        profileTextLabel.text = text
    }
    
    func setRightButtonEvent(target: Any, action: Selector) {
        guard let button = rightButton else { return }
        
        button.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setRightButtonImage(image: UIImage?) {
        guard let button = rightButton else { return }
        
        button.setImage(image, for: .normal)
    }
    
    func presentToFailedPopupViewcontroller() {
        DispatchQueue.main.async {
            let popUp = AuthenticationPopupViewController()
            popUp.modalTransitionStyle = .crossDissolve
            popUp.modalPresentationStyle = .overFullScreen
            self.window?.rootViewController?.present(popUp, animated: false)
            self.switchButton.isOn = false
        }
    }
}

extension ProfileTableViewCell: NBSwitchDelegate {
    
    func switchButtonStateChanged(isOn: Bool) {
        switch dataType {
        case .saved:
            UserManager.saveBulitInInLibrary = !isOn
        case .hideThumbnail:
            UserManager.hideThumbnail = isOn
        case .biometricAuthentication:
            if isOn { // 생체인증 on
                LocalAuthenticationService.shared.evaluateAuthentication { response, error in
                    UserManager.biometricAuthentication = response
                    if error != nil { self.presentToFailedPopupViewcontroller()
                    }
                }
            } else { // 생체인증 off
                UserManager.biometricAuthentication = isOn
            }
        default: break
        }
    }

}
