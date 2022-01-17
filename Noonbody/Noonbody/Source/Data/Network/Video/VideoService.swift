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
    
    func getVideo(with imageKeys: VideoRequestModel, completion: @escaping (Result<Int?, Error>) -> Void) {
        provider.requestNoResultAPI(VideoAPI.postImageKeyList(imageKeys: imageKeys)) { response in
            completion(response)
        }
    }
}
