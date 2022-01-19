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
    
    func editAlbum(albumId: Int, request: EditAlbumRequestModel) -> Observable<Int> {
        return Observable.create { observer -> Disposable in
            let requestReference: () = PanoramaService.shared.editAlbum(id: albumId, request: request) { response in
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
    
    func deleteAlbum(albumId: Int) -> Observable<Int> {
        Observable<Int>.create { observer -> Disposable in
            let requestReference: () = PanoramaService.shared.deleteAlbum(id: albumId) { response in
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
