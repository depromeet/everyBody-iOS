//
//  RealmManager.swift
//  Noonbody
//
//  Created by kong on 2022/03/04.
//

import UIKit

import RealmSwift

public class RealmManager {
    public static func getUrl() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("Realm Database fileUrl: ", documentDirectory)
        
        return documentDirectory
    }
    
    static func realm() -> Realm? {
        do {
              return try Realm()
        } catch {
              print(error.localizedDescription)
        }
        return nil
      }
    
    static func saveObjects(objs: Object) {
        guard let realm = RealmManager.realm() else { return }
        try? realm.write ({
            realm.add(objs)
        })
    }
    
    static func loadImageFromDocumentDirectory(imageName: String) -> UIImage? {
        
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let path = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        
        if let directoryPath = path.first {
            let imageURL = URL(fileURLWithPath: directoryPath).appendingPathComponent(imageName)
            // 3. UIImage로 불러오기
            return UIImage(contentsOfFile: imageURL.path)
        }
        
        return nil
    }
}
