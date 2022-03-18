//
//  LocalAlbums.swift
//  Noonbody
//
//  Created by kong on 2022/03/03.
//

import Foundation

import RealmSwift

class LocalAlbums: Object {
    @Persisted var localAlbums: List<LocalAlbum> = List<LocalAlbum>()
    var localAlbumArray: [Album] {
        get {
            return localAlbums.map { Album(id: $0.id, name: $0.name, thumbnailURL: "", createdAt: "", albumDescription: $0.albumDescription, pictures: Pictures(lower: $0.lowerArray, upper: $0.upperArray, whole: $0.wholeArray)) }
        }
    }
}


//extension LocalAlbums {
//    func asEntity() -> Albums {
//        return [album(]
////        let pictures = Pictures(lower: lowerArray, upper: upperArray, whole: wholeArray)
////        return Album(id: id, name: name, thumbnailURL: "", createdAt: "", albumDescription: albumDescription, pictures: pictures)
//    }
//}
