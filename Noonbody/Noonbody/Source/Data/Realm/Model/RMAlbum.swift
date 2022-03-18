//
//  RMAlbum.swift
//  Noonbody
//
//  Created by kong on 2022/03/03.
//

import Foundation

import RealmSwift

final class RMAlbum: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String = ""
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
        return (realm.objects(RMAlbum.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    func calcuateDay(createdAt: Date) -> String {
        let interval = Date().timeIntervalSince(createdAt)
        let days = Int(interval / 86400) + 1
        return "\(days)일간의 기록"
    }
}

extension RMAlbum {
    func asEntity() -> Album {
        let pictures = Pictures(lower: lowerArray, upper: upperArray, whole: wholeArray)
        let description = calcuateDay(createdAt: createdAt)
        return Album(id: id, name: name, thumbnailURL: "", createdAt: "", albumDescription: description, pictures: pictures)
    }
}
