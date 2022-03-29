//
//  DeletePictureUseCase.swift
//  Noonbody
//
//  Created by kong on 2022/03/25.
//

import Foundation

import RxSwift

protocol DeletePictureUseCase {
    func delete(pictureId: Int) -> Observable<Int>
}

final class DefaultDeletePictureUseCase: DeletePictureUseCase {
    private let repository: PictureRepository
    
    init(repository: PictureRepository) {
        self.repository = repository
    }
    
    func delete(pictureId: Int) -> Observable<Int> {
        return repository.delete(pictureId: pictureId)
    }
}
