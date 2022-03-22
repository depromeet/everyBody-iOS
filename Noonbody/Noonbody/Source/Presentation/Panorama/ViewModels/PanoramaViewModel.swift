//
//  PanoramaViewModel.swift
//  everyBody-iOS
//
//  Created by kong on 2021/11/02.
//

import Foundation

import RxSwift
import RxCocoa

final class PanoramaViewModel {
    private let fetchAlbumUseCase: FetchAlbumUseCase
    private let renameAlbumUseCase: RenameAlbumUseCase
    private let deleteAlbumUseCase: DeleteAlbumUseCase
    
    struct Input {
        let cameraViewDidDisappear: Observable<Void>
        let albumId: Int
        let albumNameTextField: Observable<String>
        let deleteAlbumButtonControlEvent: ControlEvent<Void>
        let renameButtonControlEvent: ControlEvent<Void>
    }
    
    struct Output {
        let album: Driver<Album?>
        let canRename: Driver<Bool>
        let renamedAlbum: Driver<String?>
        let deleteAlbumStatusCode: Driver<Int>
    }
    init(fetchAlbumUseCase: FetchAlbumUseCase,
         renameAlbumUseCase: RenameAlbumUseCase,
         deleteAlbumUseCase: DeleteAlbumUseCase) {
        self.fetchAlbumUseCase = fetchAlbumUseCase
        self.renameAlbumUseCase = renameAlbumUseCase
        self.deleteAlbumUseCase = deleteAlbumUseCase
    }
    
    func transform(input: Input) -> Output {
        let album = input.cameraViewDidDisappear
            .flatMap { _ in
                self.fetchAlbumUseCase.album(albumId: input.albumId) }
            .map { $0 }
            .share()
        
        let renameResponse = input.renameButtonControlEvent
            .withLatestFrom(input.albumNameTextField)
            .map { name in
                return AlbumRequestModel(name: name)
            }
            .flatMap { request in
                self.renameAlbumUseCase.rename(albumId: input.albumId, request: request)
            }
            .share()
        
        let deleteAlbumResponse = input.deleteAlbumButtonControlEvent
            .flatMap {
                self.deleteAlbumUseCase.delete(albumId: input.albumId)
            }.map { $0 }
            .share()
        
        let data = album
            .compactMap { $0 }
            .map { response -> Album in
                return response
            }.asDriver(onErrorJustReturn: nil)
        
        let canRename = input.albumNameTextField
            .map { name in
                return !name.isEmpty
            }.asDriver(onErrorJustReturn: false)
        
        let renamedAlbum = renameResponse
            .map { response -> String in
                return response.name
            }.asDriver(onErrorJustReturn: nil)
        
        let deleteAlbumStatusCode = deleteAlbumResponse
            .compactMap { $0 }
            .map { response -> Int in
                return response
            }.asDriver(onErrorJustReturn: 404)
        
        return Output(album: data, canRename: canRename, renamedAlbum: renamedAlbum, deleteAlbumStatusCode: deleteAlbumStatusCode)
    }
}
