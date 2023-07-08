//
//  File.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/11.
//

import Foundation

// MARK: - Album

struct Album: Codable {
    let id: Int
    let name: String
    let thumbnailURL: String?
    let createdAt: String
    let albumDescription: String
    var pictures: Pictures

    enum CodingKeys: String, CodingKey {
        case id, name
        case thumbnailURL = "thumbnail_url"
        case createdAt = "created_at"
        case albumDescription = "description"
        case pictures
    }
}

// MARK: - Pictures

struct Pictures: Codable {
    var lower: [PictureInfo]
    var upper: [PictureInfo]
    var whole: [PictureInfo]
}

// MARK: - PictureInfo

struct PictureInfo: Codable {
    let id, albumID: Int
    let bodyPart: BodyPart
    let thumbnailURL, previewURL, imageURL: String
    let key: String
    let takenAt: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case albumID = "album_id"
        case bodyPart = "body_part"
        case thumbnailURL = "thumbnail_url"
        case previewURL = "preview_url"
        case imageURL = "image_url"
        case key
        case takenAt = "taken_at"
        case createdAt = "created_at"
    }
}

enum BodyPart: String, Codable {
    case lower
    case upper
    case whole

    var title: String {
        switch self {
        case .lower:
            return "하체"
        case .upper:
            return "상체"
        case .whole:
            return "전신"
        }
    }
}

typealias Albums = [Album]
