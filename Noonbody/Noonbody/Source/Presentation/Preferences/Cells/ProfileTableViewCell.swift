//
//  ProfileTableViewCell.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    enum Style {
        case textField
        case right
        case appSwitch
    }
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = .nbFont(type: .body2SemiBold)
        $0.textColor = Asset.Color.gray80.color
    }
    public let profileTextField = UITextField().then {
        $0.textColor = Asset.Color.gray80.color
        $0.clearButtonMode = .whileEditing
    }
    lazy var saveOnlyInAppSwitch = CustomSwitch(width: 40, height: 24).then {
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
        case .textField:
            addSubview(profileTextField)
            rightButton?.removeFromSuperview()
            descriptionLabel.removeFromSuperview()
            saveOnlyInAppSwitch.removeFromSuperview()
            
            profileTextField.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.leading.equalToSuperview().offset(113)
                $0.trailing.equalToSuperview().offset(-20)
            }
        case .right:
            profileTextField.removeFromSuperview()
            rightButton = UIButton()
            
            guard let button = rightButton else { return }
            addSubview(button)
            
            button.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().inset(20)
            }
        case .appSwitch:
            profileTextField.removeFromSuperview()
            addSubviews(descriptionLabel, saveOnlyInAppSwitch)
            
            titleLabel.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(16)
                $0.leading.equalToSuperview().offset(20)
            }
            descriptionLabel.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(11)
                $0.leading.equalTo(titleLabel.snp.leading)
            }
            saveOnlyInAppSwitch.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.top)
                $0.trailing.equalToSuperview().offset(-20)
                $0.width.equalTo(38)
                $0.height.equalTo(24)
            }
        }
    }
    
    func setData(title: String, placeholder: String? = nil) {
        titleLabel.text = title
        
        guard let text = placeholder else { return }
        profileTextField.addPlaceHolderAttributed(text: text)
    }
    
    func setTextField(text: String) {
        profileTextField.text = text
    }
    
    func setRightButtonEvent(target: Any, action: Selector) {
        guard let button = rightButton else { return }
        
        button.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setRightButtonImage(image: UIImage?) {
        guard let button = rightButton else { return }
        
        button.setImage(image, for: .normal)
    }
    
}

extension ProfileTableViewCell: CustomSwitchDelegate {
    
    func switchButtonStateChanged(isOn: Bool) {
        UserManager.saveBulitInInLibrary = !isOn
    }

}
