//
//  Fonts.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/28.
//

import UIKit

enum TextStyles {
    case header1
    case header2
    case subtitle
    case body1
    case body2
    case body3
    case caption1
    case caption2
}

enum NBWeight: String {
    case bold = "Bold"
    case semibold = "SemiBold"
    case regular = "Regular"
}

extension UIFont {
    
    static func nbFont(type: TextStyles) -> UIFont {
        switch type {
        case .header1:
            return UIFont(name: "Pretendard-Bold", size: 28)!
        case .header2:
            return UIFont(name: "Pretendard-Bold", size: 24)!
        case .subtitle:
            return UIFont(name: "Pretendard-SemiBold", size: 20)!
        case .body1:
            return UIFont(name: "Pretendard-Regular", size: 18)!
        case .body2:
            return UIFont(name: "Pretendard-Regular", size: 18)!
        case .body3:
            return UIFont(name: "Pretendard-Regular", size: 14)!
        case .caption1:
            return UIFont(name: "Pretendard-Regular", size: 12)!
        case .caption2:
            return UIFont(name: "Pretendard-Regular", size: 10)!
        }
    }
    
    static func nbFont(ofSize fontSize: CGFloat, weight: NBWeight = .regular) -> UIFont {
        return UIFont(name: "Pretendard-\(weight)", size: fontSize)!
    }
    
}
