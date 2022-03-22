//
//  DeleteAlbumUseCase.swift
//  Noonbody
//
//  Created by kong on 2022/03/22.
//

import Foundation

import RxSwift

protocol DeleteAlbumUseCase {
    func delete(albumId: Int) -> Observable<Int>
}

final class DefaultDeleteAlbumUseCase: DeleteAlbumUseCase {
    private let repository: AlbumRepository
    
    init(repository: AlbumRepository) {
        self.repository = repository
    }
    
    func delete(albumId: Int) -> Observable<Int> {
        return repository.delete(albumId: albumId)
    }
}
