//
//  CameraViewModel.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/28.
//

import Foundation

import RxCocoa
import RxSwift

struct CameraViewModel {
    
    var allPose = [
        Pose(thumnailImage: Asset.Image.wWhole.image, guideImage: Asset.Image.womanWhole01.image),
        Pose(thumnailImage: Asset.Image.mWhole.image, guideImage: Asset.Image.manWhole01.image),
        Pose(thumnailImage: Asset.Image.wUpper.image, guideImage: Asset.Image.womanUpper02.image),
        Pose(thumnailImage: Asset.Image.mUpper.image, guideImage: Asset.Image.manUpper02.image),
        Pose(thumnailImage: Asset.Image.wUpper2.image, guideImage: Asset.Image.manLower01.image),
        Pose(thumnailImage: Asset.Image.wLower.image, guideImage: Asset.Image.womanLower01.image)
    ]

    
    func getCreationDate(metadata: [String: Any]) -> (String, String) {
        var dateString = ""

        "\(metadata["{Exif}"]!)"
            .replacingOccurrences(of: "{", with: "")
            .replacingOccurrences(of: "}", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .split(separator: ";")
            .forEach { item in
                if item.contains("DateTimeOriginal") {
                    dateString = String(item)
                }
            }
        
        if !dateString.isEmpty {
            let convertedDate = String(dateString[dateString.firstIndex(of: "\"")!..<dateString.endIndex]).replacingOccurrences(of: "\"", with: "")
            let date = AppDate(formattedDate: String(convertedDate.split(separator: " ")[0]),
                               with: ":")
                .getFormattedDate(with: ".")
            let time = String(convertedDate.split(separator: " ")[1])
            return (date, time)
        } else {
            let appDate = AppDate()
            let date = appDate.getFormattedDate(with: ".")
            let time = "\(appDate.getHour()):\(appDate.getMinute())"
            return (date, time)
        }
    }
    
}
