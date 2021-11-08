//
//  CameraViewModel.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/28.
//

import Foundation

import RxSwift

struct CameraViewModel {
 
    var camera = Camera.shared
    var creationTime: PublishSubject<String> {
        return camera.creationDate
    }
    var meridiemTime: Observable<String> {
        return camera.meridiemTime.map {
            let dateArray = $0.split(separator: ":")
            if 0 <= Int(dateArray[0])! && Int(dateArray[0])! < 13 {
                return "AM " + dateArray[0] + ":" + dateArray[1]
            } else {
                return "PM " + dateArray[0] + ":" + dateArray[1]
            }
        }
    }
}
