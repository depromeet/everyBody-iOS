//
//  CreateAlbumUseCase.swift
//  Noonbody
//
//  Created by kong on 2022/03/22.
//

import Foundation

import RxSwift

protocol CreateAlbumUseCase {
    func create(request: AlbumRequestModel) -> Observable<Album>
    func create(album: AlbumRequestModel) -> Observable<Int>
}

final class DefaultCreateAlbumUseCase: CreateAlbumUseCase {
    private let repository: AlbumRepository
    
    init(repository: AlbumRepository) {
        self.repository = repository
    }
    
    func create(request: AlbumRequestModel) -> Observable<Album> {
        return repository.create(request: request)
    }
    func create(album: AlbumRequestModel) -> Observable<Int> {
        return repository.create(album: album)
    }
}
