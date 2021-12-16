//
//  SignInResponse.swift
//  Noonbody
//
//  Created by 윤예지 on 2021/12/11.
//

import Foundation

struct SignInResponse: Codable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
