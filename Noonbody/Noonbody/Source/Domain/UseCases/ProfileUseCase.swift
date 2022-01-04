//
//  ProfileUseCase.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/25.
//

import Foundation

import RxSwift

protocol ProfileUseCase {
    func getUserInfo() -> Observable<UserInfo>
    func modifyUserInfo(request: ProfileRequestModel) -> Observable<Int>
    func getNotificationConfig() -> Observable<NotificationConfig>
    func modifyNotificationConfig(request: NotificationConfig) -> Observable<Int>
}

final class DefaultProfileUseCase: ProfileUseCase {
    
    private let preferenceRepository: PreferenceRepository

    init(preferenceRepository: PreferenceRepository) {
        self.preferenceRepository = preferenceRepository
    }
    
    func getUserInfo() -> Observable<UserInfo> {
        return preferenceRepository.getUserInfo()
    }
    
    func modifyUserInfo(request: ProfileRequestModel) -> Observable<Int> {
        return preferenceRepository.modifyUserInfo(request: request)
    }
    
    func getNotificationConfig() -> Observable<NotificationConfig> {
        return preferenceRepository.getNotificationConfig()
    }
    
    func modifyNotificationConfig(request: NotificationConfig) -> Observable<Int> {
        return preferenceRepository.modifyNotificationConfig(request: request)
    }
}
