//
//  AlbumUseCase.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/02.
//

import Foundation

import RxSwift

protocol AlbumUseCase {
    func getAlbumList() -> Observable<[Album]>
    func postCreateAlbum(request: CreateAlbumRequestModel) -> Observable<Album>
}

final class DefaultAlbumUseCase: AlbumUseCase {

    private let albumRepository: DefaultAlbumRepositry
    
    init(albumRepository: DefaultAlbumRepositry) {
        self.albumRepository = albumRepository
    }
    
    func getAlbumList() -> Observable<[Album]> {
        return albumRepository.getAlbumList()
    }
    
    func postCreateAlbum(request: CreateAlbumRequestModel) -> Observable<Album> {
        return albumRepository.postCreateAlbum(request: request)
    }
    
}
