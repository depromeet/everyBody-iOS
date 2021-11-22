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
    
    struct Input {
        let viewWillAppear: Observable<Void>
//        let nickNameTextField: Observable<String>
//        let motoTextField: Observable<String>
//        let completeButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let cellData: Driver<[PreferenceDataType]>
        let profileImage: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let response = input.viewWillAppear
            .flatMap { PreferenceService().getUserInfo() }
            .map { $0 }
            .share()
        
        let cellData = response
            .compactMap { $0 }
            .map { response -> [PreferenceDataType] in
                return [
                    .nickName(nickname: response.nickname),
                    .motto(motto: response.motto),
                    .pushNotification,
                    .saved
                ]
            }.asDriver(onErrorJustReturn: [])
        
        let imageURL = response
            .compactMap { $0 }
            .map { response -> String in
                return response.profileImage
            }.asDriver(onErrorJustReturn: "")
        
        return Output(cellData: cellData, profileImage: imageURL)
    }
    
}
