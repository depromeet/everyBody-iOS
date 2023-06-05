//
//  UITextField+attributedPlaceholder.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import UIKit

extension UITextField {
    
    func addPlaceHolderAttributed(text: String, color: UIColor = Asset.Color.Text.disabled.color) {
        attributedPlaceholder = NSAttributedString(string: text, attributes: [
            .foregroundColor: color
        ])
    }
    
}
