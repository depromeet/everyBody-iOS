//
//  DefaultSendFeedbackRepository.swift
//  Noonbody
//
//  Created by kong on 2022/03/18.
//

import Foundation

import RxSwift

class DefaultSendFeedbackRepository: SendFeedbackRepository {
    func sendFeedback(request: FeedbackRequestModel) -> Observable<Int> {
        Observable<Int>.create { observer -> Disposable in
            let requestReference: () = AlbumService.shared.sendFeedback(request: request) { response in
                switch response {
                case .success(let statusCode):
                    if let statusCode = statusCode {
                        observer.onNext(statusCode)
                    }
                case .failure(let err):
                    print(err)
                }
            }
            return Disposables.create(with: { requestReference })
        }
    }
}
