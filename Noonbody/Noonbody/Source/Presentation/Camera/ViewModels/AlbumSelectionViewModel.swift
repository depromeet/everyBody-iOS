//
//  AlbumSelectionViewModel.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/04.
//

import Foundation

import RxSwift
import RxCocoa

final class AlbumSelectionViewModel {
    
    private let albumUseCase: AlbumUseCase
    private let requestManager = CameraRequestManager.shared
    
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let album: Driver<[Album]>
    }
    
    struct PopUpInput {
        let albumNameTextField: Observable<String>
        let creationControlEvent: ControlEvent<Void>
    }
    
    struct PopUpOutput {
        let album: Driver<Album?>
    }
    
    init(albumUseCase: AlbumUseCase) {
        self.albumUseCase = albumUseCase
    }
    
    func transform(input: Input) -> Output {
        let album = input.viewWillAppear
            .flatMap {
                self.albumUseCase.getAlbumList()
            }
            .map { $0 }
            .share()
        
        let data = album
            .compactMap { $0 }
            .map { response -> [Album] in
                return response
            }.asDriver(onErrorJustReturn: [])
        
        return Output(album: data)
    }
    
    func albumCreationDidTap(input: PopUpInput) -> PopUpOutput {
    
        let album = input.creationControlEvent.withLatestFrom(input.albumNameTextField)
            .map { name in
                return CreateAlbumRequestModel(name: name)
            }
            .flatMap { requestModel -> Observable<Album> in
                return self.albumUseCase.createAlbum(request: requestModel)
            }
            .share()
        
        let data = album
            .compactMap { $0 }
            .map { response -> Album in
                return response
            }.asDriver(onErrorJustReturn: nil)
        
        return PopUpOutput(album: data)
    }
}
