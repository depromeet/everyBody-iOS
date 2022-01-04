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
}

extension PanoramaAPI {
    
    var path: String {
        switch self {
        case .getAlbum(let albumId):
            return HTTPMethodURL.GET.album + "/\(albumId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAlbum:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getAlbum:
            return .requestPlain
        }
    }
}
