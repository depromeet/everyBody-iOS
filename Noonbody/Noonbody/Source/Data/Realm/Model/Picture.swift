//
//  Picture.swift
//  Noonbody
//
//  Created by kong on 2022/03/03.
//

import Foundation

import RealmSwift

final class Picture: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var albumId: Int = 0
    @Persisted var bodyPart: String = ""
    @Persisted var directoryURL: String = ""
    @Persisted var date: String = ""
    
    convenience init(albumId: Int, bodyPart: String, directoryURL: String, date: String) {
        self.init()
        self.id = incrementID()
        self.albumId = albumId
        self.bodyPart = bodyPart
        self.directoryURL = directoryURL
        self.date = date
    }
    
    func incrementID() -> Int {
        guard let realm = RealmManager.realm() else { return 0 }
        return (realm.objects(Picture.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}
