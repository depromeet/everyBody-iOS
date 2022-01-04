//
//  PanoramaRepository.swift
//  Noonbody
//
//  Created by kong on 2022/01/02.
//

import Foundation

import RxSwift
import Moya

protocol PanoramaRepository {
    func getAlbum(albumId: Int) -> Observable<Album>
}

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
}
