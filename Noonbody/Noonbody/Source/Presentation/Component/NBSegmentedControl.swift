//
//  NBSegmentedControl.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/04.
//

import UIKit

/*
 stackView에 numOfButton 개수만큼 버튼 추가 후
 setTitle을 통해 해당하는 인덱스의 타이틀을 설정합니다.
 */

protocol NBSegmentedControlDelegate: AnyObject {
    func changeToIndex(_ segmentControl: NBSegmentedControl, at index: Int)
}

class NBSegmentedControl: UIView {

    // MARK: - UI Componentes
    
    var stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 0
        $0.distribution = .fillProportionally
    }
    
    var spacing: CGFloat = 0 {
        didSet {
            if spacing != 0 {
                stackView.spacing = spacing
                buttons.forEach { button in button.makeRounded(radius: 4) }
            }
        }
    }
    
    var buttons: [UIButton] = []
    
    // MARK: - properties
    
    enum ButtonStyle {
        case basic
        case background
        case withSpacing
    }
    
    var buttonStyle: ButtonStyle?
    var numOfButton: Int?
    weak var delegate: NBSegmentedControlDelegate?
    
    // MARK: - Initalizer
    
    init(buttonStyle: ButtonStyle, numOfButton count: Int) {
        self.init()
        self.buttonStyle = buttonStyle
        self.numOfButton = count
        self.makeRounded(radius: 4)
        
        createButton(count: count)
        setAttributes()
    }
    
    override func layoutSubviews() {
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: - Methods
    
    func setViewHierarchy() {
        addSubview(stackView)
        stackView.addArrangedSubviews(buttons)
    }
    
    func setupLayout() {
        guard let numOfButton = numOfButton else { return }
        
        setViewHierarchy()
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
   
        let padding = CGFloat(numOfButton * Int(spacing))
        for index in 0..<2 {
            buttons[index].snp.makeConstraints {
                $0.width.equalTo((self.frame.width - padding) / CGFloat(numOfButton))
            }
        }
    }
    
    func createButton(count: Int) {
        for _ in 0..<count {
            let button = buttonStyle == .basic ? NBBasicButton() : NBSegmentedButton()
            button.addTarget(self, action: #selector(self.setAction(sender:)), for: .touchUpInside)
            buttons.append(button)
        }
    }
    
    func setAttributes() {
        buttons[0].isSelected = true
    }
    
    func setTitle(at index: Int, title: String) {
        buttons[index].setTitle(title, for: .normal)
    }
    
    func setImage(at index: Int, image: UIImage) {
        buttons[index].setImage(image, for: .normal)
        buttons[index].tintColor = .black
        buttons[index].alignVertical()
    }
    
    @objc
    func setAction(sender: UIButton) {
        for (index, button) in buttons.enumerated() {
            button.isSelected = button == sender ? true : false
            if button.isSelected {
                delegate?.changeToIndex(self, at: index)
            }
        }
    }
}
