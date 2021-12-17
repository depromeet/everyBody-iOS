//
//  PoseViewModel.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/30.
//

import UIKit

import RxSwift

struct PoseViewModel {

    var allPose = [
        Pose(thumnailImage: Asset.Image.wWhole.image, guideImage: Asset.Image.womanWhole01.image),
        Pose(thumnailImage: Asset.Image.mWhole.image, guideImage: Asset.Image.manWhole01.image),
        Pose(thumnailImage: Asset.Image.wUpper.image, guideImage: Asset.Image.womanUpper02.image),
        Pose(thumnailImage: Asset.Image.mUpper.image, guideImage: Asset.Image.manUpper02.image),
        Pose(thumnailImage: Asset.Image.wUpper2.image, guideImage: Asset.Image.manLower01.image),
        Pose(thumnailImage: Asset.Image.wLower.image, guideImage: Asset.Image.womanLower01.image)
    ]

}
