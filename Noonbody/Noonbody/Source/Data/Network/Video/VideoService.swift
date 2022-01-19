//
//  VideoService.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/16.
//

import Foundation
import Moya

public class VideoService {
    
    static let shared = VideoService()
    let provider = MultiMoyaProvider(plugins: [MoyaLoggingPlugin()])
    
    private init() { }
    
    func getVideo(with imageKeys: VideoRequestModel,
                  progressCompletion: @escaping ((ProgressResponse) -> Void),
                  completion: @escaping (Result<Int?, Error>) -> Void) {
        provider.requestWithProgress(VideoAPI.postImageKeyList(imageKeys: imageKeys)) { progress in
            progressCompletion(progress)
        } completion: { response in
            completion(response)
        }

    }
}
