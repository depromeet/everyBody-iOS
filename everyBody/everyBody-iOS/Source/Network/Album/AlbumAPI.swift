//
//  AlbumAPI.swift
//  everyBody-iOS
//
//  Created by kong on 2021/12/03.
//

import Foundation

import Moya

enum AlbumAPI: BaseTargetType {
    typealias ResultModel = [Album]
    
    case getAlbumList
}

extension AlbumAPI {
    
    var path: String {
        switch self {
        case .getAlbumList:
            return HTTPMethodURL.GET.album
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAlbumList:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getAlbumList:
            return .requestPlain
        }
    }
}
