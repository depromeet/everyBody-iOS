//
//  AlbumViewModel.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/11.
//

import Foundation

import RxSwift
import RxCocoa

final class AlbumViewModel {
    
    private let albumUseCase: FetchAlbumsUseCase
    private let feedbackUseCase: AlbumUseCase
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let content: Observable<String>
        let starRate: Observable<Int>
        let sendButtonControlEvent: ControlEvent<Void>
    }
    
    struct Output {
        let album: Driver<[Album]>
        let canSend: Driver<Bool>
        let sendFeedbackStatusCode: Driver<Int>
    }
    
    init(albumUseCase: FetchAlbumsUseCase, feedbackUseCase: AlbumUseCase) {
        self.albumUseCase = albumUseCase
        self.feedbackUseCase = feedbackUseCase
    }
    
    func transform(input: Input) -> Output {
        
        let requestObservable = Observable.combineLatest(input.content, input.starRate)
        
        let album = input.viewWillAppear
            .flatMap {
                self.albumUseCase.albums() }
            .map { $0 }
            .share()
        
        let data = album
            .compactMap { $0 }
            .map { response -> [Album] in
                return response
            }.asDriver(onErrorJustReturn: [])
        
        let canSend = requestObservable
            .map { content, statRate in
                return !content.isEmpty && statRate != 0
            }.asDriver(onErrorJustReturn: false)
        
        let sendFeedbackResponse = input.sendButtonControlEvent
            .withLatestFrom(requestObservable)
            .map { content, starRate in
                return FeedbackRequestModel(content: content, starRate: starRate)
            }
            .flatMap { request in
                self.feedbackUseCase.sendFeedback(request: request)
            }
            .map { $0 }
            .share()
        
        let sendFeedbackStatusCode = sendFeedbackResponse
            .compactMap { $0 }
            .map { response -> Int in
                return response
            }.asDriver(onErrorJustReturn: 404)
        
        return Output(album: data, canSend: canSend, sendFeedbackStatusCode: sendFeedbackStatusCode)
    }
}
