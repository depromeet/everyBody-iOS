//
//  VideoUseCase.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/16.
//

import Foundation

import RxSwift

protocol VideoUseCase {
    func downloadVideo(imageKeys: VideoRequestModel) -> Observable<Int>
}

final class DefaultVideoUseCase: VideoUseCase {
    
    private let videoRepository: DefaultVideoRepository
    
    init(videoRepository: DefaultVideoRepository) {
        self.videoRepository = videoRepository
    }
    
    func downloadVideo(imageKeys: VideoRequestModel) -> Observable<Int> {
        return videoRepository.downloadVideo(imageKeys: imageKeys)
    }

}
