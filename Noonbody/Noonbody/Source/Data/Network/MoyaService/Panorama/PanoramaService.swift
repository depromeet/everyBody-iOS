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
    
    func deletePicture(id: Int, completion: @escaping (Result<Int?, Error>) -> Void) {
        provider.requestNoResultAPI(PanoramaAPI.deletePicture(pictureId: id)) { response in
            completion(response)
        }
    }
    
    func renameAlbum(id: Int, request: AlbumRequestModel, completion: @escaping (Result<RenamedAlbum?, Error>) -> Void) {
        provider.requestDecodedMultiRepsonse(PanoramaAPI.renameAlbum(albumId: id, request: request), RenamedAlbum.self) { response in
            completion(response)
        }
    }
    
    func deleteAlbum(id: Int, completion: @escaping (Result<Int?, Error>) -> Void) {
        provider.requestNoResultAPI(PanoramaAPI.deleteAlbum(albumId: id)) { response in
             completion(response)
        }
    }
}
