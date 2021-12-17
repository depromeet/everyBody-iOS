//
//  UIImage+resizeImage.swift
//  Noonbody
//
//  Created by 윤예지 on 2021/12/16.
//

import UIKit

extension UIImage {
    func resizeImage(to size: CGSize, point: CGPoint = .zero) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: point, size: size))
        }
    }
}

