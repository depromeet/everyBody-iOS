//
//  PictureRepository.swift
//  Noonbody
//
//  Created by kong on 2022/03/25.
//

import Foundation

import RxSwift

protocol PictureRepository {
    func save(request: PictureRequestModel) -> Observable<Int>
    func delete(pictureId: Int) -> Observable<Int>
}
