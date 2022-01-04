//
//  AuthAPI.swift
//  Noonbody
//
//  Created by 윤예지 on 2021/12/11.
//

import Foundation

import Moya

enum AuthAPI: BaseTargetType {
    typealias ResultModel = SignInResponse
    
    case postSignUp(request: SignUpRequestModel)
    case postSignIn(request: SignInRequestModel)
}

extension AuthAPI {
    
    var path: String {
        switch self {
        case .postSignUp:
            return HTTPMethodURL.POST.signUp
        case .postSignIn:
            return HTTPMethodURL.POST.singIn
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postSignUp, .postSignIn:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .postSignUp(let request):
            return .requestParameters(parameters: ["password": request.password,
                                                   "device": [
                                                    "device_token": request.device.deviceToken,
                                                    "push_token": request.device.pushToken,
                                                    "device_os": "IOS"
                                                   ],
                                                   "kind": "SIMPLE"],
                                      encoding: JSONEncoding.default)
        case .postSignIn(let request):
            return .requestParameters(parameters: ["user_id": Int(request.userId)!,
                                                   "password": request.password],
                                      encoding: JSONEncoding.default)
        }
    }
    
}
