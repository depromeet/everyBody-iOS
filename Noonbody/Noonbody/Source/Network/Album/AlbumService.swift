//
//  AlbumService.swift
//  everyBody-iOS
//
//  Created by kong on 2021/12/03.
//

import Foundation

import Moya

public class AlbumService {
    
    static let shared = AlbumService()
    let provider = MultiMoyaProvider(plugins: [MoyaLoggingPlugin()])
    
    private init() { }
    
    func getAlbumList(completion: @escaping (Result<[Album]?, Error>) -> Void) {
        provider.requestDecoded(AlbumAPI.getAlbumList) { response in
            completion(response)
        }
    }
}
