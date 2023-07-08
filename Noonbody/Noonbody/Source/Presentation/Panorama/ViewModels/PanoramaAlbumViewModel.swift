//
//  PanoramaAlbumViewModel.swift
//  Noonbody
//
//  Created by kong on 2023/06/28.
//

import Foundation

import RxSwift
import RxCocoa

final class PanoramaAlbumViewModel {
    private let deletePictureUseCase: DeletePictureUseCase

    struct Input {
        let deletePictureId: Observable<Int>
        let deletePictureButtonControlEvent: ControlEvent<Void>
    }

    struct Output {
        let deletePictureStatusCode: Driver<Int>
        let deletedPictureId: Driver<Int>
    }

    init(deletePictureUseCase: DeletePictureUseCase) {
        self.deletePictureUseCase = deletePictureUseCase
    }

    func transform(input: Input) -> Output {
        let deletePictureResponse = input.deletePictureButtonControlEvent
            .withLatestFrom(input.deletePictureId)
            .flatMap { id in
                self.deletePictureUseCase.delete(pictureId: id)
            }
            .share()

        let deletePictureStatusCode = deletePictureResponse
            .compactMap { $0 }
            .map { result -> Int in
                return result
            }.asDriver(onErrorJustReturn: 404)

        let deletedPictureId = deletePictureResponse
            .compactMap { $0 }
            .withLatestFrom(input.deletePictureId)
            .map { id in
                return id
            }.asDriver(onErrorJustReturn: -1)

        return Output(deletePictureStatusCode: deletePictureStatusCode, deletedPictureId: deletedPictureId)
        }
    }
