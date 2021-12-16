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
        let profileImage: Driver<String>
    }
    
    struct CellOutput {
        let canSave: Driver<Bool>
    }
    
    init(profileUseCase: DefaultProfileUseCase) {
        self.profileUseCase = profileUseCase
    }
    
    func transform(input: Input) -> Output {
        let userInfo = input.viewWillAppear
            .flatMap { self.profileUseCase.getUserInfo() }
            .map { $0 }
            .share()
        
        let cellData = userInfo
            .compactMap { $0 }
            .map { response -> [ProfileDataType] in
                return [
                    .nickName(nickname: response.nickname),
                    .motto(motto: response.motto),
                    .pushNotification,
                    .saved
                ]
            }.asDriver(onErrorJustReturn: [])
        
        let imageURL = userInfo
            .compactMap { $0 }
            .map { response -> String in
                return response.profileImage
            }.asDriver(onErrorJustReturn: "")
        
        return Output(cellData: cellData, profileImage: imageURL)
    }
    
    func transformCellData(input: CellInput) -> CellOutput {
        let requestObservable = Observable.combineLatest(input.nickNameTextField, input.mottoTextfield)
        
        let canSave = requestObservable
            .map { nickname, motto in
                return !nickname.isEmpty && !motto.isEmpty
            }.asDriver(onErrorJustReturn: false)
        
        _ = input.completeButtonTap.withLatestFrom(requestObservable)
            .map { nickname, motto in
                UserDefaults.standard.set(nickname, forKey: "nickname")
                UserDefaults.standard.set(motto, forKey: "motto")
                return ProfileRequestModel(nickname: nickname,
                                           motto: motto)
            }
            .subscribe { request in
                self.profileUseCase.putUserInfo(request: request)
            }
        
        return CellOutput(canSave: canSave)
    }
    
}
