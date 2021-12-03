//
//  CreateAlbumService.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/02.
//

import Foundation

public class CreateAlbumService {

    static let shared = CreateAlbumService()
    let provider = MultiMoyaProvider()
    
    private init() { }
  
    func postCreateAlbum(request: CreateAlbumRequestModel, completion: @escaping (Result<Int?, Error>) -> Void) {
        provider.requestNoResultAPI(CreateAlbumAPI.postCreateAlbum(request: request)) { response in
            completion(response)
        }
    }
}
