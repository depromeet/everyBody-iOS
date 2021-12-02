//
//  AlbumUseCase.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/02.
//

import Foundation

protocol AlbumUseCase {
    func postCreateAlbum(request: CreateAlbumRequestModel)
}

class DefaultAlbumUseCase: AlbumUseCase {
    
    private let albumRepository: AlbumRepository
    
    init(albumRepository: AlbumRepository) {
        self.albumRepository = albumRepository
    }
    
    func postCreateAlbum(request: CreateAlbumRequestModel) {
        return albumRepository.postCreateAlbum(request: request)
    }
    
}
