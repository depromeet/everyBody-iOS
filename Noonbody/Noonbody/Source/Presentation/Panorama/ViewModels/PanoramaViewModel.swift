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
    private let panoramaUseCase: PanoramaUseCase
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let albumId: Int
        let albumNameTextField: Observable<String>
        let deleteButtonControlEvent: ControlEvent<Void>
        let editButtonControlEvent: ControlEvent<Void>
    }
    
    struct Output {
        let album: Driver<Album?>
        let canEdit: Driver<Bool>
        let putStatusCode: Driver<Int>
        let deleteStatusCode: Driver<Int>
    }
    
    init(panoramaUseCase: PanoramaUseCase) {
        self.panoramaUseCase = panoramaUseCase
    }
    
    func transform(input: Input) -> Output {
        let album = input.viewWillAppear
            .flatMap {
                self.panoramaUseCase.getAlbum(albumId: input.albumId) }
            .map { $0 }
            .share()
        
        let putResponse =
        input.editButtonControlEvent
            .withLatestFrom(input.albumNameTextField)
            .map { name in
                return EditAlbumRequestModel(name: name)
            }
            .flatMap { request in
                self.panoramaUseCase.editAlbum(albumId: input.albumId, request: request)
            }
            .share()
        
        let deleteResponse = input.deleteButtonControlEvent
            .flatMap {
                self.panoramaUseCase.deleteAlbum(albumId: input.albumId)
            }.map { $0 }
            .share()
        
        let data = album
            .compactMap { $0 }
            .map { response -> Album in
                return response
            }.asDriver(onErrorJustReturn: nil)
        
        let canEdit = input.albumNameTextField
            .map { name in
                return !name.isEmpty
            }.asDriver(onErrorJustReturn: false)
        
        let putStatusCode = putResponse
            .compactMap { $0 }
            .map { response -> Int in
                return response
            }.asDriver(onErrorJustReturn: 404)
        
        let deleteStatusCode = deleteResponse
            .compactMap { $0 }
            .map { response -> Int in
                return response
            }.asDriver(onErrorJustReturn: 404)
        
        return Output(album: data, canEdit: canEdit, putStatusCode: putStatusCode, deleteStatusCode: deleteStatusCode)
    }
}
