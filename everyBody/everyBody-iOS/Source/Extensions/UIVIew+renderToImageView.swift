//
//  UIVIew+renderToImageView.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/18.
//

import UIKit.UIImage

extension UIView {
    func renderToImageView() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let image = renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        
        return image
    }
}
