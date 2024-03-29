//
//  ProfileViewModel.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import Foundation

import RxSwift
import RxCocoa

final class ProfileViewModel {
    
    private let profileUseCase: DefaultProfileUseCase
    
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct CellInput {
        let nickNameTextField: Observable<String>
        let mottoTextfield: Observable<String>
        let completeButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let cellData: Driver<[ProfileDataType]>
    }
    
    struct CellOutput {
        let canSave: Driver<Bool>
        let statusCode: Driver<Int>
    }
    
    init(profileUseCase: DefaultProfileUseCase) {
        self.profileUseCase = profileUseCase
    }
    
    func transform(input: Input) -> Output {
        let cellData = input.viewWillAppear
            .compactMap { UserManager.motto }
            .map { motto -> [ProfileDataType] in
                return [
                    .motto(motto: motto),
//                    .pushNotification,
                    .saved,
                    .hideThumbnail,
                    .biometricAuthentication,
                    .privacyPolicy,
                    .instagram
                ]
            }.asDriver(onErrorJustReturn: [])
        
        return Output(cellData: cellData)
    }
    
    func transformCellData(input: CellInput) -> CellOutput {
        let requestObservable = Observable.combineLatest(input.nickNameTextField, input.mottoTextfield)
        
        let canSave = requestObservable
            .map { nickname, motto in
                return !nickname.isEmpty && !motto.isEmpty
            }.asDriver(onErrorJustReturn: false)
        
        let response = input.completeButtonTap.withLatestFrom(requestObservable)
            .map { nickname, motto in
                UserManager.nickname = nickname
                UserManager.motto = motto
                return ProfileRequestModel(nickname: nickname,
                                           motto: motto)
            }
            .flatMap { request in
                self.profileUseCase.modifyUserInfo(request: request)
            }
            .share()
        
        let statusCode = response
            .compactMap { $0 }
            .map { response -> Int in
                return response
            }.asDriver(onErrorJustReturn: 404)
        
        return CellOutput(canSave: canSave, statusCode: statusCode)
    }
    
}
