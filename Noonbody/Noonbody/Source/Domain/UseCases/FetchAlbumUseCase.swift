//
//  FetchAlbumUseCase.swift
//  Noonbody
//
//  Created by kong on 2022/03/22.
//

import Foundation

import RxSwift

protocol FetchAlbumUseCase {
    func album(albumId: Int) -> Observable<Album>
}

final class DefaultFetchAlbumUseCase: FetchAlbumUseCase {
    private let repository: AlbumRepository
    
    init(repository: AlbumRepository) {
        self.repository = repository
    }
    
    func album(albumId: Int) -> Observable<Album> {
        return repository.album(albumId: albumId)
    }
}
