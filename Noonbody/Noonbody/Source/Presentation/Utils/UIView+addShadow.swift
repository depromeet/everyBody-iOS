//
//  UIView+addShadow.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/17.
//

import UIKit.UIView

extension UIView {
    
    func addShadow(offset: CGSize, color: UIColor = UIColor.black, opacity: Float = 0.04, radius: CGFloat = 4.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
}
