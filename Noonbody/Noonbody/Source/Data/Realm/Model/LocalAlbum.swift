//
//  Album.swift
//  Noonbody
//
//  Created by kong on 2022/03/03.
//

import Foundation

import RealmSwift

class LocalAlbum: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String = ""
    @Persisted var albumDescription: String = "일 간의 기록"
    @Persisted var createdAt = Date()
    @Persisted var whole: List<Picture> = List<Picture>()
    @Persisted var upper: List<Picture> = List<Picture>()
    @Persisted var lower: List<Picture> = List<Picture>()
    
    var wholeArray: [PictureInfo] {
        get {
            return whole.map {
                PictureInfo(id: $0.id, albumID: id, bodyPart: BodyPart.whole, thumbnailURL: "", previewURL: "", imageURL: "", key: "", takenAt: $0.date, createdAt: $0.date)
                 }
        }
    }
    
    var upperArray: [PictureInfo] {
        get {
            return upper.map { PictureInfo(id: $0.id, albumID: id, bodyPart: BodyPart.upper, thumbnailURL: "", previewURL: "", imageURL: "", key: "", takenAt: $0.date, createdAt: $0.date) }
        }
    }
    
    var lowerArray: [PictureInfo] {
        get {
            return lower.map { PictureInfo(id: $0.id, albumID: id, bodyPart: BodyPart.lower, thumbnailURL: "", previewURL: "", imageURL: "", key: "", takenAt: $0.date, createdAt: $0.date) }
        }
    }

    convenience init(name: String, createdAt: Date) {
        self.init()
        self.id = incrementID()
        self.name = name
        self.createdAt = createdAt
    }
    
    func incrementID() -> Int {
        guard let realm = RealmManager.realm() else { return 0 }
        return (realm.objects(LocalAlbum.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}

extension LocalAlbum {
    func asEntity() -> Album {
        let pictures = Pictures(lower: lowerArray, upper: upperArray, whole: wholeArray)
        return Album(id: id, name: name, thumbnailURL: "", createdAt: "", albumDescription: albumDescription, pictures: pictures)
    }
}
