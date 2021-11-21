//
//  PreferenceRepository.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import Foundation

import RxSwift

protocol PreferenceRepository {
    func getUserInfo() -> Observable<UserInfo>
}

class PreferenceService: PreferenceRepository {
    
    func getUserInfo() -> Observable<UserInfo> {
        return .just(UserInfo(id: 20, nickname: "육영이", motto: "앙큼 안꽁이의 눈바디 도전기.", height: 160, weight: 100, kind: "SIMPLE", profileImage: "https://everybody-public-drive.s3.ap-northeast-2.amazonaws.com/beam-2.png", createdAt: "2021-11-02T13:53:44+09:00"))
    }

}
