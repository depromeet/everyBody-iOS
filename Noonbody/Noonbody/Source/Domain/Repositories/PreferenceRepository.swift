//
//  ProfileRepository.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/05.
//

import Foundation

import RxSwift

protocol PreferenceRepository {
    func getUserInfo() -> Observable<UserInfo>
    func modifyUserInfo(request: ProfileRequestModel) -> Observable<Int>
    func getNotificationConfig() -> Observable<NotificationConfig>
    func modifyNotificationConfig(request: NotificationConfig) -> Observable<Int>
}
