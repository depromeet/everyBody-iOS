//
//  Picture.swift
//  Noonbody
//
//  Created by kong on 2022/03/03.
//

import Foundation

import RealmSwift

class Picture: Object {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var date: String = ""
    
    convenience init(date: String) {
        self.init()
        self.id = incrementID()
        self.date = date
    }
    
    func incrementID() -> Int {
        guard let realm = RealmManager.realm() else { return 0 }
        return (realm.objects(Picture.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}
