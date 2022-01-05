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
    
    private let albumUseCase: AlbumUseCase
    
    struct Input {
        let viewWillAppear: Observable<Void>
    }
    
    struct Output {
        let album: Driver<[Album]>
    }
    
    init(albumUseCase: AlbumUseCase) {
        self.albumUseCase = albumUseCase
    }
    
    func transform(input: Input) -> Output {
        let album = input.viewWillAppear
            .flatMap {
                self.albumUseCase.getAlbumList() }
            .map { $0 }
            .share()
        
        let data = album
            .compactMap { $0 }
            .map { response -> [Album] in
                return response
            }.asDriver(onErrorJustReturn: [])
        
        return Output(album: data)
    }
}