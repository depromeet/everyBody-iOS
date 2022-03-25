//
//  AlbumCreationViewModel.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/02.
//

import Foundation

import RxCocoa
import RxSwift

final class AlbumCreationViewModel {
    
    private let albumUseCase: CreateAlbumUseCase
    
    struct Input {
        let albumNameTextField: Observable<String>
        let saveButtonControlEvent: ControlEvent<Void>
    }
    
    struct Output {
        let canSave: Driver<Bool>
        let statusCode: Driver<Int>
    }
    
    init(albumUseCase: CreateAlbumUseCase) {
        self.albumUseCase = albumUseCase
    }
    
    func transform(input: Input) -> Output {
        let canSave = input.albumNameTextField
            .map { name in
                return !name.isEmpty
            }.asDriver(onErrorJustReturn: false)
    
        let response = input.saveButtonControlEvent.withLatestFrom(input.albumNameTextField)
            .map { name in
                return AlbumRequestModel(name: name)
            }
            .flatMap { requestModel in
                self.albumUseCase.create(album: requestModel)
            }
            .share()
        
        let statusCode = response
            .compactMap { $0 }
            .map { response -> Int in
                return response
            }.asDriver(onErrorJustReturn: 404)
        
        return Output(canSave: canSave, statusCode: statusCode)
    }
    
}
