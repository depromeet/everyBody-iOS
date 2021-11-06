//
//  UIStackView+addArrangedSubviews.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/04.
//

import UIKit

extension UIStackView {
    public func addArrangedSubviews(_ view: [UIView]) {
        view.forEach { self.addArrangedSubview($0) }
    }
}
