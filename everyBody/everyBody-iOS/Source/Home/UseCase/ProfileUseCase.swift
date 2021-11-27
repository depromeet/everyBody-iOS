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
}

final class DefaultProfileUseCase: ProfileUseCase {
    
    private let preferenceRepository: ProfileRepository

    init(preferenceRepository: ProfileRepository) {
        self.preferenceRepository = preferenceRepository
    }
    
    func getUserInfo() -> Observable<UserInfo> {
        return preferenceRepository.getUserInfo()
    }
    
    func putUserInfo(request: ProfileRequestModel) {
        return preferenceRepository.putUserInfo(request: request)
    }
    
}
