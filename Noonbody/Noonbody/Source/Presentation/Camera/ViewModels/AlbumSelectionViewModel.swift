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
    private let disposeBag = DisposeBag()
    let isLoading = BehaviorRelay<Bool>(value: false)
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let saveButtonControlEvent: ControlEvent<Void>
        let albumSelection: Driver<IndexPath>
        let photoRequestModel: Observable<PhotoRequestModel>
        let albumNameTextField: Observable<String>
        let creationControlEvent: ControlEvent<Void>
    }
    
    struct Output {
        let album: Driver<[Album]>
        let newAlbum: Driver<Album?>
        let statusCode: Driver<Int>
    }
    
    init(albumUseCase: AlbumUseCase) {
        self.albumUseCase = albumUseCase
    }
    
    func transform(input: Input) -> Output {
        let albums = input.viewWillAppear
            .flatMap { self.albumUseCase.getAlbumList() }
            .map { $0 }
            .share()
        
        let data = albums
            .compactMap { $0 }
            .map { response -> [Album] in
                return response
            }.asDriver(onErrorJustReturn: [])

        let save = input.saveButtonControlEvent
            .withLatestFrom(input.photoRequestModel)
            .do(onNext: { _ in self.isLoading.accept(true) })
            .flatMap { request in
                self.albumUseCase.savePhoto(request: request)
            }
            .do(onNext: { _ in self.isLoading.accept(false)})
            .share()

        let statusCode = save
            .compactMap { $0 }
            .map { statusCode -> Int in
                return statusCode
            }.asDriver(onErrorJustReturn: 404)
        
        let albumResponse = input.creationControlEvent
            .withLatestFrom(input.albumNameTextField)
            .map { name in
                return AlbumRequestModel(name: name)
            }
            .flatMap { requestModel -> Observable<Album> in
                return self.albumUseCase.createAlbum(request: requestModel)
            }
            .share()
        
        let newAlbum = albumResponse
            .compactMap { $0 }
            .map { response -> Album in
                return response
            }.asDriver(onErrorJustReturn: nil)
        
        return Output(album: data, newAlbum: newAlbum, statusCode: statusCode)
    }
    
}
