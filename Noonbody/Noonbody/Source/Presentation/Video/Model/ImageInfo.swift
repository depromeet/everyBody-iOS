//
//  ImageInfo.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/18.
//

import Foundation

class ImageInfo: NSObject {
    let imageKey: String
    let imageURL: String
    
    init(imageKey: String, imageURL: String) {
        self.imageKey = imageKey
        self.imageURL = imageURL
    }
}
