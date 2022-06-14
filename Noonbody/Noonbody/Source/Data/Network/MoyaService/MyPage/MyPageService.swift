//
//  MyPageService.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/26.
//

import Foundation
import Moya

public class MyPageService {

    static let shared = MyPageService()
    let provider = MultiMoyaProvider()
    
    private init() { }
    
    func getMyPage(completion: @escaping (Result<UserInfo?, Error>) -> Void) {
        provider.requestDecoded(MyPageAPI.getMyPage) { response in
            completion(response)
        }
    }
    
    func putMyPage(request: ProfileRequestModel, completion: @escaping (Result<Int?, Error>) -> Void) {
        provider.requestNoResultAPI(MyPageAPI.putMyPage(request: request)) { response in
            completion(response)
        }
    }
    
    func putDownloadCompleted(completion: @escaping (Result<Int?, Error>) -> Void) {
        provider.requestNoResultAPI(MyPageAPI.putDownloadCompleted) { response in
            completion(response)
        }
    }
}
