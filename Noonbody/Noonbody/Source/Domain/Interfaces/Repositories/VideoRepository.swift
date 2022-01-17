//
//  VideoRepository.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/16.
//

import Foundation

import RxSwift

protocol VideoRepository {
    func downloadVideo(imageKeys: VideoRequestModel) -> Observable<Int>
}
