//
//  UserInfo.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import Foundation

// MARK: - UserInfo

struct UserInfo: Codable {
    let id: Int
    let nickname, motto: String
    let height, weight: Int?
    let kind: String
    let profileImage: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, nickname, motto, height, weight, kind
        case profileImage = "profile_image"
        case createdAt = "created_at"
    }
}
