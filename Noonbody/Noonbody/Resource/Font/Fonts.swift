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
    case header2Semibold
    case subtitle
    case body1
    case body1Bold
    case body2
    case body2Bold
    case body2SemiBold
    case body3
    case body3Semibold
    case caption1
    case caption1Semibold
    case caption2
    case caption2Semibold
}

enum NBWeight: String {
    case bold = "Bold"
    case semibold = "SemiBold"
    case regular = "Regular"
}

enum FontType: String {
    case gilroy = "Gilory"
    case pretendard = "Pretendard"
}

extension UIFont {
    
    static func nbFont(type: TextStyles) -> UIFont {
        switch type {
        case .header1:
            return UIFont(name: "Pretendard-Bold", size: 28)!
        case .header2:
            return UIFont(name: "Pretendard-Bold", size: 24)!
        case .header2Semibold:
            return UIFont(name: "Pretendard-Bold", size: 24)!
        case .subtitle:
            return UIFont(name: "Pretendard-SemiBold", size: 20)!
        case .body1:
            return UIFont(name: "Pretendard-Regular", size: 18)!
        case .body1Bold:
            return UIFont(name: "Pretendard-Bold", size: 18)!
        case .body2:
            return UIFont(name: "Pretendard-Regular", size: 16)!
        case .body2Bold:
            return UIFont(name: "Pretendard-Bold", size: 16)!
        case .body2SemiBold:
            return UIFont(name: "Pretendard-Semibold", size: 16)!
        case .body3:
            return UIFont(name: "Pretendard-Regular", size: 14)!
        case .body3Semibold:
            return UIFont(name: "Pretendard-SemiBold", size: 14)!
        case .caption1:
            return UIFont(name: "Pretendard-Regular", size: 12)!
        case .caption1Semibold:
            return UIFont(name: "Pretendard-SemiBold", size: 12)!
        case .caption2:
            return UIFont(name: "Pretendard-Regular", size: 10)!
        case .caption2Semibold:
            return UIFont(name: "Pretendard-SemiBold", size: 10)!
        }
    }
    
    static func nbFont(ofSize fontSize: CGFloat, weight: NBWeight = .regular, type: FontType = .pretendard) -> UIFont {
        return UIFont(name: "\(type)-\(weight)", size: fontSize)!
    }
    
}
