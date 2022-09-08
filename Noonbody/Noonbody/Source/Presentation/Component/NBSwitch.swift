//
//  CustomSwitchView.swift
//  Noonbody
//
//  Created by 윤예지 on 2021/10/30.
//

import UIKit

import RxSwift
import RxGesture

protocol NBSwitchDelegate: AnyObject {
    func switchButtonStateChanged(isOn: Bool)
}

class NBSwitch: UIView {
    
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
        $0.isHidden = true
    }
    var toggleOnColor = Asset.Color.keyPurple.color
    var toggleOffColor = Asset.Color.gray60.color
    
    // MARK: - Properties
    
    weak var delegate: NBSwitchDelegate?
    
    let disposeBag = DisposeBag()
    var isOn: Bool = true {
        didSet {
            isOn ? toggleSwitchOn() : toggleSwitchOff()
        }
    }
    var defaultKey: String?
    
    lazy var type: Style = .basic
    
    // MARK: - Initializer
    
    convenience init(width: CGFloat, height: CGFloat) {
        self.init()
        frame = CGRect(x: 0, y: 0, width: width, height: height)
        circleView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        
        setLayout()
        setAttribute()
        setInitalState()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bind()
        render()
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
    
    private func setInitalState() {
        isOn ? toggleSwitchOn() : toggleSwitchOff()
    }
    
    func bind() {
        self.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [self] _ in
                isOn.toggle()
                isOn ? toggleSwitchOn() : toggleSwitchOff()
                delegate?.switchButtonStateChanged(isOn: isOn)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    func toggleSwitchOn() {
        makeVibrate()
        circleView.snp.remakeConstraints {
            $0.top.trailing.bottom.equalToSuperview().inset(2)
            $0.width.height.equalTo(20)
        }
        UIView.animate(withDuration: 0.2) { [self] in
            layoutIfNeeded()
            backgroundColor = toggleOnColor
            if type == .text {
                descriptionLabel.isHidden = false
            }
        }
    }
    
    func toggleSwitchOff() {
        makeVibrate()
        circleView.snp.remakeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(2)
            $0.width.height.equalTo(20)
        }
        UIView.animate(withDuration: 0.2) { [self] in
            layoutIfNeeded()
            backgroundColor = toggleOffColor
            descriptionLabel.isHidden = true
        }
    }
    
}
