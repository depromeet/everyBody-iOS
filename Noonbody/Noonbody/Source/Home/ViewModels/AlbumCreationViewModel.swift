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
    
    private let albumUseCase: AlbumUseCase
    
    struct Input {
        let albumNameTextField: Observable<String>
        let saveButtonControlEvent: ControlEvent<Void>
    }
    
    struct Output {
        let canSave: Driver<Bool>
    }
    
    init(albumUseCase: DefaultAlbumUseCase) {
        self.albumUseCase = albumUseCase
    }
    
    func transform(input: Input) -> Output {
        let canSave = input.albumNameTextField
            .map { name in
                return !name.isEmpty
            }.asDriver(onErrorJustReturn: false)
    
        _ = input.saveButtonControlEvent.withLatestFrom(input.albumNameTextField)
            .map { name in
                return CreateAlbumRequestModel(name: name)
            }
            .subscribe(onNext: { requestModel in
                self.albumUseCase.postCreateAlbum(request: requestModel)
            })
        
        return Output(canSave: canSave)
    }
    
}
