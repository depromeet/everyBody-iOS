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
        Pose(thumnailImage: UIImage(), guideImage: UIImage()),
        Pose(thumnailImage: Asset.Image.samplePose.image, guideImage: Asset.Image.womanWhole01.image),
        Pose(thumnailImage: Asset.Image.samplePose.image, guideImage: Asset.Image.womanUpper02.image),
        Pose(thumnailImage: Asset.Image.samplePose.image, guideImage: Asset.Image.womanLower01.image),
        Pose(thumnailImage: Asset.Image.samplePose.image, guideImage: Asset.Image.manWhole01.image),
        Pose(thumnailImage: Asset.Image.samplePose.image, guideImage: Asset.Image.manUpper02.image),
        Pose(thumnailImage: Asset.Image.samplePose.image, guideImage: Asset.Image.manLower01.image)
    ]
    
    lazy var poseSubject = BehaviorSubject<[Pose]>(value: allPose)
    
}
