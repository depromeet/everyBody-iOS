//
//  LocalAlbumRepositories.swift
//  Noonbody
//
//  Created by kong on 2022/03/11.
//

import Foundation

import RxSwift

protocol LocalAlbumRepository {
    func getAlbumList() -> Observable<[LocalAlbum]>
    func createAlbum(request: AlbumRequestModel) -> Observable<Album>
    func createAlbum(request: AlbumRequestModel) -> Observable<Int>
    func savePhoto(request: PhotoRequestModel) -> Observable<Int>
//    func savePhoto(request: PhotoRequestModel)
}
