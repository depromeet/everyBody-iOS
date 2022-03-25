//
//  FetchAlbumsUseCase.swift
//  Noonbody
//
//  Created by kong on 2022/03/18.
//

import Foundation

import RxSwift

protocol FetchAlbumsUseCase {
    func albums() -> Observable<[Album]>
}

final class DefaultFetchAlbumsUseCase: FetchAlbumsUseCase {
    private let repository: AlbumRepository
    
    init(repository: AlbumRepository) {
        self.repository = repository
    }
    
    func albums() -> Observable<[Album]> {
        return repository.albums()
    }
}
