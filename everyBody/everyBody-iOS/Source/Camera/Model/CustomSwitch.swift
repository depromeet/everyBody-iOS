//
//  CustomSwitchView.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/30.
//

import UIKit

import RxSwift
import RxGesture

class CustomSwitch: UIView {
    
    // MARK: - UI Components
    
    var circleView = UIView().then {
        $0.backgroundColor = .white
    }
    var descriptionLabel = UILabel().then {
        $0.text = "그리드"
        $0.font = .nbFont(ofSize: 10, weight: .semibold)
        $0.textColor = .white
        $0.isHidden = true
    }
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag()
    var isToggleSubject = BehaviorSubject<Bool>(value: false)
    var isSwitchOn: Bool = false
    
    // MARK: - Initializer
    
    convenience init(width: CGFloat, height: CGFloat) {
        self.init()
        frame = CGRect(x: 0, y: 0, width: width, height: height)
        circleView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        setLayout()
        setAttribute()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        render()
        setLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func render() {
        backgroundColor = Asset.Color.gray60.color
    }
    
    func setAttribute() {
        makeRounded(radius: self.bounds.height / 2)
        circleView.makeRounded(radius: circleView.frame.height / 2)
    }
    
    func setLayout() {
        addSubviews(circleView, descriptionLabel)
        
        circleView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(2)
            $0.width.height.equalTo(20)
            circleView.makeRounded(radius: 10)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(8)
        }
    }
    
    func bind() {
        self.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [self] _ in
                isToggleSubject.onNext(isSwitchOn)
            })
            .disposed(by: disposeBag)
        
        isToggleSubject
            .map { $0 }
            .subscribe(onNext: { [self] in
                $0 ? toggleSwitchOn() : toggleSwitchOff()
                self.isSwitchOn.toggle()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    func toggleSwitchOn() {
        UIView.animate(withDuration: 0.2) { [self] in
            circleView.center.x += 35
            backgroundColor = Asset.Color.keyPurple.color
            descriptionLabel.isHidden = false
        }
    }
    
    func toggleSwitchOff() {
        UIView.animate(withDuration: 0.2) { [self] in
            circleView.center.x -= 35
            backgroundColor = Asset.Color.gray60.color
            descriptionLabel.isHidden = true
        }
    }

}
