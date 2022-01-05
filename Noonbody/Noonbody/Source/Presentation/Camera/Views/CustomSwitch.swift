//
//  CustomSwitchView.swift
//  Noonbody
//
//  Created by 윤예지 on 2021/10/30.
//

import UIKit

import RxSwift
import RxGesture

class CustomSwitch: UIView {
    
    enum Style {
        case basic
        case text
    }
    
    // MARK: - UI Components
    
    var circleView = UIView().then {
        $0.backgroundColor = .white
        $0.addShadow(offset: CGSize(width: 0, height: 0), opacity: 1.0, radius: 10)
    }
    var descriptionLabel = UILabel().then {
        $0.text = "그리드"
        $0.font = .nbFont(type: .caption2Semibold)
        $0.textColor = .white
    }
    var toggleOnColor = Asset.Color.keyPurple.color
    var toggleOffColor = Asset.Color.gray60.color
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag()
    var isToggleSubject = BehaviorSubject<Bool>(value: true)
    var isOn: Bool = true
    
    lazy var type: Style = .basic
    
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
        
        bind()
        render()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func render() {
        backgroundColor = Asset.Color.keyPurple.color
    }
    
    func setAttribute() {
        makeRounded(radius: self.bounds.height / 2)
        circleView.makeRounded(radius: circleView.frame.height / 2)
    }
    
    func setOffColor(color: UIColor = Asset.Color.gray60.color) {
        toggleOffColor = color
    }
    
    func setOnColor(color: UIColor = Asset.Color.keyPurple.color) {
        toggleOnColor = color
    }
    
    func setLayout() {
        addSubviews(circleView, descriptionLabel)
        
        circleView.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview().inset(2)
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
                isToggleSubject.onNext(isOn)
            })
            .disposed(by: disposeBag)
        
        isToggleSubject
            .map { $0 }
            .subscribe(onNext: { [self] in
                $0 ? toggleSwitchOn() : toggleSwitchOff()
                self.isOn.toggle()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    func toggleSwitchOn() {
        makeVibrate()
        UIView.animate(withDuration: 0.2) { [self] in
            circleView.center.x += self.frame.width - self.circleView.frame.width - 4
            backgroundColor = toggleOnColor
            if type == .text {
                descriptionLabel.isHidden = false
            }
        }
    }
    
    func toggleSwitchOff() {
        makeVibrate()
        UIView.animate(withDuration: 0.2) { [self] in
            circleView.center.x -= self.frame.width - self.circleView.frame.width - 4
            backgroundColor = toggleOffColor
            descriptionLabel.isHidden = true
        }
    }
    
}
