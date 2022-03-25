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
    func createAlbum(request: AlbumRequestModel) -> Observable<Album>
    func createAlbum(requestModel: AlbumRequestModel) -> Observable<Int>
}

final class DefaultAlbumUseCase: AlbumUseCase {

    private let albumRepository: AlbumRepository
    
    init(albumRepository: AlbumRepository) {
        self.albumRepository = albumRepository
    }
    
    func getAlbumList() -> Observable<[Album]> {
        return albumRepository.albums()
    }
    
    func createAlbum(request: AlbumRequestModel) -> Observable<Album> {
        return albumRepository.create(request: request)
    }
    
    func createAlbum(requestModel: AlbumRequestModel) -> Observable<Int> {
        return albumRepository.create(album: requestModel)
    }
}
