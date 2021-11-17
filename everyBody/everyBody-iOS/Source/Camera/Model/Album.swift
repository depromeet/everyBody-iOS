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
    let pictures: Pictures

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
    let lower: [PictureInfo]
    let upper: [PictureInfo]
    let whole: [PictureInfo]
}

// MARK: - PictureInfo

struct PictureInfo: Codable {
    let id, albumID: Int
    let bodyPart: BodyPart
    let thumbnailURL, previewURL, imageURL: String
    let key: String
    let takenAtYear, takenAtMonth, takenAtDay: Int
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case albumID = "album_id"
        case bodyPart = "body_part"
        case thumbnailURL = "thumbnail_url"
        case previewURL = "preview_url"
        case imageURL = "image_url"
        case key
        case takenAtYear = "taken_at_year"
        case takenAtMonth = "taken_at_month"
        case takenAtDay = "taken_at_day"
        case createdAt = "created_at"
    }
}

enum BodyPart: String, Codable {
    case lower
    case upper
    case whole
}

typealias Albums = [Album]
