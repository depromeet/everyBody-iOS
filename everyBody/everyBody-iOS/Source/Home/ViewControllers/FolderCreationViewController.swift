//
//  FolderCreationViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/23.
//

import UIKit

class FolderCreationViewController: BaseViewController {

    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = .nbFont(type: .header2Semibold)
        $0.textColor = Asset.Color.gray90.color
        $0.text = "폴더명을\n입력해주세요."
        $0.numberOfLines = 0
    }
    
    private lazy var folderTextfield = NBTextField().then {
        $0.setPlaceHoder(placehoder: "폴더명을 입력해주세요")
        $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private lazy var saveButton = NBPrimaryButton().then {
        $0.setTitle("저장", for: .normal)
        $0.rounding = 28
        $0.addTarget(self, action: #selector(saveButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupContraint()
        setupKeyboardEvent()
        hideKeyboard()
    }
    
    // MARK: - Methods
    
    private func setupKeyboardEvent() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    // MARK: - Actions
    
    @objc
    private func keyboardWillShow(_ sender: Notification) {
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
            self.saveButton.transform = CGAffineTransform(translationX: 0, y: -260)
        })
    }
    
    @objc
    private func keyboardWillHide(_ sender: Notification) {
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
            self.saveButton.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }
    
    @objc
    private func textFieldDidChange() {
        if let text = folderTextfield.text, !text.isEmpty {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    @objc
    private func saveButtonDidTap() {
        
    }
    
}

// MARK: - Layout

extension FolderCreationViewController {
    
    private func setupContraint() {
        view.addSubviews(titleLabel, folderTextfield, saveButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(31)
            $0.leading.equalToSuperview().offset(20)
        }
        
        folderTextfield.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(56)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
        }
    }
    
}
