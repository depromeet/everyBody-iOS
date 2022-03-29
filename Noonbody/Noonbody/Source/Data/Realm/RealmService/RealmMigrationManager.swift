//
//  RealmMigrationManager.swift
//  Noonbody
//
//  Created by kong on 2022/03/29.
//

import Foundation

import RealmSwift

public class RealmMigrationManager {
    static func renameProperty(migration: Migration, object: String, oldName: String, newName: String) {
        migration.renameProperty(onType: object, from: oldName, to: newName)
    }
    
    static func modifyType(migration: Migration, object: String, initialValue: Any) {
        migration.enumerateObjects(ofType: object) { oldObject, newObject in
            newObject![object] = "\(oldObject![object] ?? initialValue)"
        }
    }
}
