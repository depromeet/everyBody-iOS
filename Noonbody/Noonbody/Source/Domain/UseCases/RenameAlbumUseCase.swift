//
//  RenameAlbumUseCase.swift
//  Noonbody
//
//  Created by kong on 2022/03/22.
//

import Foundation

import RxSwift

protocol RenameAlbumUseCase {
    func rename(albumId: Int, request: AlbumRequestModel) -> Observable<RenamedAlbum>
}

final class DefaultRenameAlbumUseCase: RenameAlbumUseCase {
    private let repository: AlbumRepository
    
    init(repository: AlbumRepository) {
        self.repository = repository
    }
    
    func rename(albumId: Int, request: AlbumRequestModel) -> Observable<RenamedAlbum> {
        return repository.rename(albumId: albumId, request: request)
    }
}
