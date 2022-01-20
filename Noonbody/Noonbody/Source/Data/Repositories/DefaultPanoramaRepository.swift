//
//  DefaultPanoramaRepository.swift
//  Noonbody
//
//  Created by kong on 2022/01/02.
//

import Foundation

import RxSwift
import Moya

class DefaultPanoramaRepository: PanoramaRepository {
    func getAlbum(albumId: Int) -> Observable<Album> {
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
    
    func renameAlbum(albumId: Int, request: RenameAlbumRequestModel) -> Observable<String> {
        let observable = Observable<String>.create { observer -> Disposable in
            let requestReference: () = PanoramaService.shared.renameAlbum(id: albumId, request: request) { response in
                switch response {
                case .success(let data):
                    if let data = data {
                        observer.onNext(data.name)
                    }
                case .failure(let err):
                    print(err)
                }
            }
            return Disposables.create(with: { requestReference })
        }
        return observable
    }
    
    func deleteAlbum(albumId: Int) -> Observable<Int> {
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
}
