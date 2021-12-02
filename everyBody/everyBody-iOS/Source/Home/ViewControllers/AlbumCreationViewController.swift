//
//  AlbumCreationViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/23.
//

import UIKit

import RxSwift

class AlbumCreationViewController: BaseViewController {

    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = .nbFont(type: .header2Semibold)
        $0.textColor = Asset.Color.gray90.color
        $0.text = "폴더명을\n입력해주세요."
        $0.numberOfLines = 0
    }
    
    private lazy var albumTextfield = NBTextField().then {
        $0.setPlaceHoder(placehoder: "폴더명을 입력해주세요")
    }
    
    private lazy var saveButton = NBPrimaryButton().then {
        $0.setTitle("저장", for: .normal)
        $0.rounding = 28
        $0.addTarget(self, action: #selector(saveButtonDidTap), for: .touchUpInside)
    }
    
    // MARK: - Properties
    
    private let viewModel = AlbumCreationViewModel(albumUseCase: DefaultAlbumUseCase(
                                                   albumRepository: DefaultAlbumRepositry()))
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setupContraint()
        setupKeyboardEvent()
        hideKeyboard()
    }
    
    // MARK: - Methods
    
    private func bind() {
        let input = AlbumCreationViewModel.Input(albumNameTextField: albumTextfield.rx.text.orEmpty.asObservable(),
                                                 saveButtonControlEvent: saveButton.rx.tap)
        let ouput = viewModel.transform(input: input)
        
        ouput.canSave
            .drive(saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
    }
    
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
        if let keyboardFrame: NSValue = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
                self.saveButton.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight)
            })
        }
    }
    
    @objc
    private func keyboardWillHide(_ sender: Notification) {
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
            self.saveButton.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }

    @objc
    private func saveButtonDidTap() {
        
    }
    
}

// MARK: - Layout

extension AlbumCreationViewController {
    
    private func setupContraint() {
        view.addSubviews(titleLabel, albumTextfield, saveButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(31)
            $0.leading.equalToSuperview().offset(20)
        }
        
        albumTextfield.snp.makeConstraints {
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
