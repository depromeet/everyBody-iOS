//
//  PanoramaAPI.swift
//  Noonbody
//
//  Created by kong on 2022/01/02.
//

import Foundation

import Moya

enum PanoramaAPI: BaseTargetType {
    typealias ResultModel = Album
    
    case getAlbum(albumId: Int)
    case renameAlbum(albumId: Int, request: RenameAlbumRequestModel)
    case deleteAlbum(albumId: Int)
}

extension PanoramaAPI {
    
    var path: String {
        switch self {
        case .getAlbum(let albumId):
            return HTTPMethodURL.GET.album + "/\(albumId)"
        case .renameAlbum(let albumId, _):
            return HTTPMethodURL.PUT.album + "/\(albumId)"
        case .deleteAlbum(let albumId):
            return HTTPMethodURL.DELETE.album + "/\(albumId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAlbum:
            return .get
        case .renameAlbum:
            return .put
        case .deleteAlbum:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .getAlbum:
            return .requestPlain
        case .renameAlbum(_, let request):
            return .requestParameters(parameters: ["name": request.name],
                                      encoding: JSONEncoding.default)
        case .deleteAlbum:
            return .requestPlain
        }
    }
}
