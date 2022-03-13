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
    var localAlbumArray: [LocalAlbum] {
        get {
            return localAlbums.map { $0 }
        }
    }
}
