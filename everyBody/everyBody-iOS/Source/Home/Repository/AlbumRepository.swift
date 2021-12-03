//
//  AlbumRepository.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/02.
//

import Foundation

import RxSwift
import Moya

protocol AlbumRepository {
    func getAlbumList() -> Observable<[Album]>
//    func getAlbumDetail(albumId: Int) -> Observable<Album>
    func postCreateAlbum(request: CreateAlbumRequestModel)
}

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
    
//    func getAlbumDetail(albumId: Int) -> Observable<Album> {
//        let observable = Observable<Album>.create { observer -> Disposable in
//            let requestReference: () = AlbumService.shared.getAlbumDetail(albumId: albumId) { response in
//                switch response {
//                case .success(let data):
//                    if let data = data {
//                        observer.onNext(data)
//                    }
//                case .failure(let err):
//                    print(err)
//                }
//            }
//            return Disposables.create(with: { requestReference })
//        }
//        return observable
//    }
    
    func postCreateAlbum(request: CreateAlbumRequestModel) {
        CreateAlbumService.shared.postCreateAlbum(request: request) { response in
            switch response {
            case .success:
                print("성공적으로 생성되었습니다.")
            case .failure:
                print("알 수 없는 에러가 발생했습니다.")
            }
        }
    }
    
}
