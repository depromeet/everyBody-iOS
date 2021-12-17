//
//  UIViewController+makeVibrate.swift
//  Noonbody
//
//  Created by 윤예지 on 2021/12/17.
//

import UIKit

extension UIView {
    public func makeVibrate(degree: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: degree)
        generator.impactOccurred()
    }
}
