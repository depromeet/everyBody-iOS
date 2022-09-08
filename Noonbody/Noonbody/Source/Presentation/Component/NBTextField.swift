//
//  NBTextField.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/17.
//

import UIKit

class NBTextField: UITextField {
    
    open var borderSize: CGFloat = 1
    
    open var borderColor: UIColor = Asset.Color.gray90.color
    
    var cornerRadius: CGFloat = 8
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        delegate = self
        render()
        addLeftPadding()
        setBorder()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func render() {
        backgroundColor = .white
    }
    
    private func setBorder() {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderSize
        layer.borderColor = borderColor.cgColor
    }
    
    func setPlaceHoder(placehoder: String) {
        addPlaceHolderAttributed(text: placehoder)
    }
}

extension NBTextField: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addShadow(offset: CGSize(width: 0, height: 0), radius: 10)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        layer.shadowOpacity = 0.0
    }
    
}
