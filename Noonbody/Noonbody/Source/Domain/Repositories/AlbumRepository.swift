//
//  AlbumRepository.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/05.
//

import Foundation

import RxSwift

protocol AlbumRepository {
    func albums() -> Observable<[Album]>
    func album(albumId: Int) -> Observable<Album>
    func create(request: AlbumRequestModel) -> Observable<Album>
    func create(album: AlbumRequestModel) -> Observable<Int>
    func delete(albumId: Int) -> Observable<Int>
    func rename(albumId: Int, request: AlbumRequestModel) -> Observable<RenamedAlbum>
    
    // PhotoRepository로
    func savePhoto(request: PhotoRequestModel) -> Observable<Int>
}
