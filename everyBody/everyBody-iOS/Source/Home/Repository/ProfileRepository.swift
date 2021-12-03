//
//  PreferenceRepository.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import Foundation

import RxSwift
import Moya

protocol ProfileRepository {
    func getUserInfo() -> Observable<UserInfo>
    func putUserInfo(request: ProfileRequestModel)
    func getNotificationConfig() -> Observable<NotificationConfig>
    func putNotificationConfig(request: NotificationConfig)
}

class DefaultProfileRepository: ProfileRepository {
    
    func getUserInfo() -> Observable<UserInfo> {
        let observable = Observable<UserInfo>.create { observer -> Disposable in
            let requestReference: () = MyPageService.shared.getMyPage { response in
                switch response {
                case .success(let data):
                    if let data = data {
                        observer.onNext(data)
                    }
                case .failure(let err):
                    print(err)
                }
            }
            return Disposables.create(with: { requestReference })
        }
        return observable
    }
    
    func putUserInfo(request: ProfileRequestModel) {
        MyPageService.shared.putMyPage(request: request) { response in
            // TODO: .success 혹은 .failure일 때 어떤 뷰 만들건지 디자인과 상의 후 변경(임시 print 문)
            switch response {
            case .success:
                print("성공적으로 변경되었습니다.")
            case .failure:
                print("알 수 없는 에러가 발생했습니다.")
            }
        }
    }
    
    func getNotificationConfig() -> Observable<NotificationConfig> {
        return Observable.create { observer -> Disposable in
            let requestReference: () = NotificationService.shared.getNotificationConfig { response in
                switch response {
                case .success(let data):
                    if let data = data {
                        observer.onNext(data)
                    }
                case .failure(let err):
                    print(err)
                }
            }
            return Disposables.create(with: { requestReference })
        }
    }
    
    func putNotificationConfig(request: NotificationConfig) {
        NotificationService.shared.putNotificationConfig(request: request) { response in
            switch response {
            case .success:
                print("성공적으로 변경되었습니다.")
            case .failure:
                print("알 수 없는 에러가 발생했습니다.")
            }
        }
    }
    
}
