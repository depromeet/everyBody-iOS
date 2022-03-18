//
//  DefaultAlbumRepositry.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/02.
//

import Foundation

import RealmSwift
import RxSwift
import Moya

class DefaultAlbumRepositry: AlbumRepository {
    func albums() -> Observable<[Album]> {
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
    
    func album(albumId: Int) -> Observable<Album> {
        let observable = Observable<Album>.create { observer -> Disposable in
            let requestReference: () = PanoramaService.shared.getAlbum(id: albumId) { response in
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
    
    func create(request: AlbumRequestModel) -> Observable<Album> {
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
    
    func create(album: AlbumRequestModel) -> Observable<Int> {
        return Observable<Int>.create { observer -> Disposable in
            let requestReference: () = CreateAlbumService.shared.postCreateAlbum(request: album) { response in
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
    
    func delete(albumId: Int) -> Observable<Int> {
        Observable<Int>.create { observer -> Disposable in
            let requestReference: () = PanoramaService.shared.deleteAlbum(id: albumId) { response in
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
    
    func rename(albumId: Int, request: AlbumRequestModel) -> Observable<RenamedAlbum> {
        let observable = Observable<RenamedAlbum>.create { observer -> Disposable in
            let requestReference: () = PanoramaService.shared.renameAlbum(id: albumId, request: request) { response in
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
