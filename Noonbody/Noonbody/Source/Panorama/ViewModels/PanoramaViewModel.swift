//
//  PanoramaViewModel.swift
//  everyBody-iOS
//
//  Created by kong on 2021/11/02.
//

import Foundation
import UIKit

class PanoramaViewModel {
    var albumTitle: String = "예꽁이의 섹시눈바디"
    var phothArray: [UIImage] = [Asset.Image.del.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.add.image, Asset.Image.sample.image, Asset.Image.back.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image,
                                 Asset.Image.del.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.add.image, Asset.Image.sample.image, Asset.Image.back.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image, Asset.Image.sample.image]

    var wholebody: [UIImage] = []
    var upperbody: [UIImage] = []
    var lowerbody: [UIImage] = []
    
    var deleteArray: [Int] = []
}
