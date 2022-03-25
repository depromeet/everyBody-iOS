//
//  DefaultPreferenceRepository.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import Foundation

import RxSwift
import Moya

class DefaultPreferenceRepository: PreferenceRepository {
    
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
    
    func modifyUserInfo(request: ProfileRequestModel) -> Observable<Int> {
        return Observable.create { observer -> Disposable in
            let requestReference: () = MyPageService.shared.putMyPage(request: request) { response in
                switch response {
                case .success:
                    observer.onNext(200)
                case .failure(let err):
                    print(err)
                }
            }
            return Disposables.create(with: { requestReference })
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
    
    func modifyNotificationConfig(request: NotificationConfig) -> Observable<Int> {
        return Observable.create { observer -> Disposable in
            let requestReference: () = NotificationService.shared.putNotificationConfig(request: request) { response in
                switch response {
                case .success:
                    observer.onNext(200)
                case .failure(let err):
                    print(err)
                }
            }
            return Disposables.create(with: { requestReference })
        }
    }
    
}
