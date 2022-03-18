//
//  RMAlbums.swift
//  Noonbody
//
//  Created by kong on 2022/03/03.
//

import Foundation

import RealmSwift

final class RMAlbums: Object {
    @Persisted var rmAlbums: List<RMAlbum> = List<RMAlbum>()
    var localAlbumArray: [Album] {
        get {
            return rmAlbums.map { Album(id: $0.id, name: $0.name, thumbnailURL: "", createdAt: "", albumDescription: $0.calcuateDay(createdAt: $0.createdAt), pictures: Pictures(lower: $0.lowerArray, upper: $0.upperArray, whole: $0.wholeArray)) }
        }
    }
}
