//
//  DefaultAlbumRepositry.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/02.
//

import Foundation

import RxSwift
import Moya

class DefaultAlbumRepositry: AlbumRepository {
    
    func getAlbumList() -> Observable<[Album]> {
        let observable = Observable<[Album]>.create { observer -> Disposable in
            let requestReference: () = AlbumService.shared.getAlbumList { response in
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
    
    func createAlbum(request: CreateAlbumRequestModel) -> Observable<Album> {
        let observable = Observable<Album>.create { observer -> Disposable in
            let requestReference: () = CreateAlbumService.shared.postCreateAlbum(request: request) { response in
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
    
    func createAlbum(request: CreateAlbumRequestModel) -> Observable<Int> {
        return Observable<Int>.create { observer -> Disposable in
            let requestReference: () = CreateAlbumService.shared.postCreateAlbum(request: request) { response in
                switch response {
                case .success:
                    observer.onNext(200)
                case .failure(let err):
                    observer.onError(err)
                }
            }
            return Disposables.create(with: { requestReference })
        }
    }
    
    @discardableResult
    func deletePicture(pictureId: Int) -> Observable<Int> {
        Observable<Int>.create { observer -> Disposable in
            let requestReference: () = AlbumService.shared.deletePicture(id: pictureId) { response in
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
    
    @discardableResult
    func savePhoto(request: PhotoRequestModel) -> Observable<Int> {
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
}
