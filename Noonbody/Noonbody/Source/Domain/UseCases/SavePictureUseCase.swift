//
//  SavePictureUseCase.swift
//  Noonbody
//
//  Created by kong on 2022/03/25.
//

import Foundation

import RxSwift

protocol SavePictureUseCase {
    func save(request: PictureRequestModel) -> Observable<Int>
}

final class DefaultSavePictureUseCase: SavePictureUseCase {
    private let repository: PictureRepository
    
    init(repository: PictureRepository) {
        self.repository = repository
    }
    
    func save(request: PictureRequestModel) -> Observable<Int> {
        return repository.save(request: request)
    }
}
