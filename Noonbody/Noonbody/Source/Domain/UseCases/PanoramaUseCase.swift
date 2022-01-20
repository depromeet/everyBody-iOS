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
    func renameAlbum(albumId: Int, request: RenameAlbumRequestModel) -> Observable<RenameAlbumResponse>
    func deleteAlbum(albumId: Int) -> Observable<Int>
}

final class DefaultPanoramaUseCase: PanoramaUseCase {
    private let panoramaRepository: DefaultPanoramaRepository
    
    init(panoramaRepository: DefaultPanoramaRepository) {
        self.panoramaRepository = panoramaRepository
    }
    
    func getAlbum(albumId: Int) -> Observable<Album> {
        return panoramaRepository.getAlbum(albumId: albumId)
    }
    
    func renameAlbum(albumId: Int, request: RenameAlbumRequestModel) -> Observable<RenameAlbumResponse> {
        return panoramaRepository.renameAlbum(albumId: albumId, request: request)
    }
    
    func deleteAlbum(albumId: Int) -> Observable<Int> {
        return panoramaRepository.deleteAlbum(albumId: albumId)
    }
}
