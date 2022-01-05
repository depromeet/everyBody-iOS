//
//  MyPageService.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/26.
//

import Foundation
import Moya

enum MyPageAPI: BaseTargetType {
    typealias ResultModel = UserInfo
    
    case getMyPage
    case putMyPage(request: ProfileRequestModel)
}

extension MyPageAPI {
    
    var path: String {
        switch self {
        case .getMyPage:
            return HTTPMethodURL.GET.userInfo
        case .putMyPage:
            return HTTPMethodURL.PUT.userInfo
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getMyPage:
            return .get
        case .putMyPage:
            return .put
        }
    }
    
    var task: Task {
        switch self {
        case .getMyPage:
            return .requestPlain
        case .putMyPage(let request):
            return .requestParameters(parameters: ["nickname": request.nickname,
                                                   "motto": request.motto],
                                      encoding: JSONEncoding.default)
        }
    }

}
