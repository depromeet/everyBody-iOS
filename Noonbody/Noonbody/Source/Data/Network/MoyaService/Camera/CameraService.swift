//
//  CameraService.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/04.
//

import Foundation

import Moya

public class CameraService {

    static let shared = CameraService()
    let provider = MultiMoyaProvider(plugins: [MoyaLoggingPlugin()])
    
    private init() { }
        
    func postPhoto(request: PictureRequestModel, completion: @escaping (Result<Int?, Error>) -> Void) {
        provider.requestNoResultAPI(CameraAPI.postPhoto(request: request)) { response in
            completion(response)
        }
    }
}
