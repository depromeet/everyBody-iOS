//
//  RenameAlbumResponse.swift
//  Noonbody
//
//  Created by kong on 2022/01/21.
//

import Foundation

struct RenameAlbumResponse: Codable {
    let name: String

    enum CodingKeys: String, CodingKey {
        case name
    }
}
