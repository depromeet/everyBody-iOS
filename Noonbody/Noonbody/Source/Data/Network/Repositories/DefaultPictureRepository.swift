//
//  DefaultPictureRepository.swift
//  Noonbody
//
//  Created by kong on 2022/05/28.
//

import Foundation

import RealmSwift
import RxSwift
import Moya

class DefaultPictureRepository: PictureRepository {
    func save(request: PictureRequestModel) -> Observable<Int> {
        Observable<Int>.create { observer -> Disposable in
            let requestReference: () = CameraService.shared.postPhoto(request: request) { response in
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
    
    func delete(pictureId: Int) -> Observable<Int> {
        Observable<Int>.create { observer -> Disposable in
            let requestReference: () = PanoramaService.shared.deletePicture(id: pictureId) { response in
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
