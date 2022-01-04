//
//  SignUpService.swift
//  Noonbody
//
//  Created by 윤예지 on 2021/12/11.
//

import Foundation

public class AuthService {

    static let shared = AuthService()
    let provider = MultiMoyaProvider(plugins: [MoyaLoggingPlugin()])
    
    private init() { }
    
    func postSignUp(request: SignUpRequestModel, completion: @escaping (Result<UserInfo?, Error>) -> Void) {
        provider.requestDecodedMultiRepsonse(AuthAPI.postSignUp(request: request), UserInfo.self) { response in
            completion(response)
        }
    }
    
    func postSignIn(request: SignInRequestModel, completion: @escaping (Result<SignInResponse?, Error>) -> Void) {
        provider.requestDecodedMultiRepsonse(AuthAPI.postSignIn(request: request), SignInResponse.self) { response in
            completion(response)
        }
    }
}
