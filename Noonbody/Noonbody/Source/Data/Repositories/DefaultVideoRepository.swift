//
//  DefaultVideoRepository.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/16.
//

import Foundation

import RxSwift

let progress: PublishSubject<Double> = PublishSubject<Double>()

class DefaultVideoRepository: VideoRepository {
    
    func downloadVideo(imageKeys: VideoRequestModel) -> Observable<Int> {
        Observable<Int>.create { observer -> Disposable in
            let requestReference: () = VideoService.shared.getVideo(with: imageKeys) { progressResponse in
                progress.onNext(progressResponse.progress)
            } completion: { response in
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
