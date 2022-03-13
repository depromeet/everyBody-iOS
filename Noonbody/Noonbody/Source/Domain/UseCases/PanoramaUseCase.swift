//
//  PanoramaUseCase.swift
//  Noonbody
//
//  Created by kong on 2022/01/02.
//

import Foundation

import RxSwift

protocol PanoramaUseCase {
    func getAlbum(albumId: Int) -> Observable<LocalAlbum>
    func deletePicture(pictureId: Int) -> Observable<Int>
    func renameAlbum(albumId: Int, request: AlbumRequestModel) -> Observable<RenamedAlbum>
    func deleteAlbum(albumId: Int) -> Observable<Int>
}

final class DefaultPanoramaUseCase: PanoramaUseCase {
    private let panoramaRepository: DefaultPanoramaRepository
    
    init(panoramaRepository: DefaultPanoramaRepository) {
        self.panoramaRepository = panoramaRepository
    }
    func getAlbum(albumId: Int) -> Observable<LocalAlbum> {
        return panoramaRepository.getAlbum(albumId: albumId)
    }
    
    func deletePicture(pictureId: Int) -> Observable<Int> {
        return panoramaRepository.deletePicture(pictureId: pictureId)
    }
    
    func renameAlbum(albumId: Int, request: AlbumRequestModel) -> Observable<RenamedAlbum> {
        return panoramaRepository.renameAlbum(albumId: albumId, request: request)
    }
    
    func deleteAlbum(albumId: Int) -> Observable<Int> {
        return panoramaRepository.deleteAlbum(albumId: albumId)
    }
}
