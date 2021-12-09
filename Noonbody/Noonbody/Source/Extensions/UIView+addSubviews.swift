//
//  UIView+addSubview.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/13.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            self.addSubview(view)
        }
    }
}
