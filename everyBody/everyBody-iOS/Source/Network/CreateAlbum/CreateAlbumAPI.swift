//
//  CreateAlbumAPI.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/02.
//

import Foundation

import Moya

enum CreateAlbumAPI: BaseTargetType {
    typealias ResultModel = String
    
    case postCreateAlbum(request: CreateAlbumRequestModel)
}

extension CreateAlbumAPI {
    
    var path: String {
        switch self {
        case .postCreateAlbum:
            return HTTPMethodURL.POST.createAlbum
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postCreateAlbum:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .postCreateAlbum(let request):
            return .requestParameters(parameters: ["name": request.name],
                                      encoding: JSONEncoding.default)
        }
    }

}
