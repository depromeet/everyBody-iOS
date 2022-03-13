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
    
    var wholeArray: [Picture] {
        get {
            return whole.map { $0 }
        }
    }
    
    var upperArray: [Picture] {
        get {
            return upper.map { $0 }
        }
    }
    
    var lowerArray: [Picture] {
        get {
            return lower.map { $0 }
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
