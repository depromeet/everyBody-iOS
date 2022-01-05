//
//  UIView+makeRounded.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/13.
//

import UIKit

extension UIView {
    func makeRounded(radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
    }
    
    func makeRoundedWithBorder(radius: CGFloat, color: CGColor, borderWith: CGFloat = 1) {
        makeRounded(radius: radius)
        self.layer.borderWidth = borderWith
        self.layer.borderColor = color
    }
}
