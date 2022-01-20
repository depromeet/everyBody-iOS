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
    
    func renameAlbum(id: Int, request: RenameAlbumRequestModel, completion: @escaping (Result<Int?, Error>) -> Void) {
        provider.requestNoResultAPI(PanoramaAPI.renameAlbum(albumId: id, request: request)) { response in
            completion(response)
        }
    }
    
    func deleteAlbum(id: Int, completion: @escaping (Result<Int?, Error>) -> Void) {
        provider.requestNoResultAPI(PanoramaAPI.deleteAlbum(albumId: id)) { response in
             completion(response)
        }
    }
}
