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
    case deletePicture(pictureId: Int)
}

extension AlbumAPI {
    
    var path: String {
        switch self {
        case .getAlbumList:
            return HTTPMethodURL.GET.album
        case .deletePicture(let pictureId):
            return HTTPMethodURL.DELETE.pictures + "/\(pictureId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAlbumList:
            return .get
        case .deletePicture:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .getAlbumList:
            return .requestPlain
        case .deletePicture:
            return .requestPlain
        }
    }
}
