//
//  UIImageView+setImage.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/22.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImage(with imagePath: String) {
        guard let url = URL(string: imagePath) else { return }
        self.kf.setImage(
            with: url,
            placeholder: UIImage(),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.45)),
                .cacheOriginalImage
            ]) { result in
            switch result {
            case .success:
                return
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
    }
}
