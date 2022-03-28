//
//  PictureRequestModel.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/04.
//

import UIKit.UIImage

struct PictureRequestModel {
    let image: UIImage
    let albumId: Int
    let bodyPart: BodyPart
    let takenAt: String
    
    enum BodyPart: String {
        case whole, upper, lower
    }
}
