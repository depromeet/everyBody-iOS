//
//  PanoramaService.swift
//  Noonbody
//
//  Created by kong on 2022/01/02.
//

import Foundation

public class PanoramaService {
    
    static let shared = PanoramaService()
    let provider = MultiMoyaProvider(plugins: [MoyaLoggingPlugin()])
    
    private init() { }
    
    func getAlbum(id: Int, completion: @escaping (Result<Album?, Error>) -> Void) {
        provider.requestDecoded(PanoramaAPI.getAlbum(albumId: id)) { response in
            completion(response)
        }
    }
}
