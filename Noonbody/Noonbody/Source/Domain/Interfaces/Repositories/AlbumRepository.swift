//
//  AlbumRepository.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/05.
//

import Foundation

import RxSwift

protocol AlbumRepository {
    func getAlbumList() -> Observable<[Album]>
    func createAlbum(request: CreateAlbumRequestModel) -> Observable<Album>
    func createAlbum(request: CreateAlbumRequestModel) -> Observable<Int>
    func deletePicture(pictureId: Int) -> Observable<Int>
}
