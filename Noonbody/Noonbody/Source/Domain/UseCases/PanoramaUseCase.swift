//
//  PanoramaUseCase.swift
//  Noonbody
//
//  Created by kong on 2022/01/02.
//

import Foundation

import RxSwift

protocol PanoramaUseCase {
    func getAlbum(albumId: Int) -> Observable<Album>
}

final class DefaultPanoramaUseCase: PanoramaUseCase {
    private let panoramaRepository: DefaultPanoramaRepository
    
    init(panoramaRepository: DefaultPanoramaRepository) {
        self.panoramaRepository = panoramaRepository
    }
    
    func getAlbum(albumId: Int) -> Observable<Album> {
        return panoramaRepository.getAlbum(albumId: albumId)
    }
}
