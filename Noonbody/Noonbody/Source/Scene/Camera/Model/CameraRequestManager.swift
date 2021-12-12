//
//  CameraRequestManager.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/04.
//

import UIKit.UIImage

class CameraRequestManager {
    static let shared = CameraRequestManager()
    
    var image: UIImage = UIImage()
    var albumId: Int = 0
    var bodyPart: String = "whole"
    var takenAt: String = ""
}
