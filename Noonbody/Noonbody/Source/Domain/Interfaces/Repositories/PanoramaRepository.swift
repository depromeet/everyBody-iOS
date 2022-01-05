//
//  PanoramaRepository.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/05.
//

import Foundation

import RxSwift

protocol PanoramaRepository {
    func getAlbum(albumId: Int) -> Observable<Album>
}
