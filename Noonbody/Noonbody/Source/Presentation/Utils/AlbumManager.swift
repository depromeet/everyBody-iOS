//
//  AlbumManager.swift
//  Noonbody
//
//  Created by kong on 2022/03/13.
//

import UIKit

import RealmSwift

public class AlbumManager {
    static func loadImageFromDocumentDirectory(imageName: String) -> UIImage? {
        let documentDirectory = RealmManager.getUrl()
        let imageURL = documentDirectory.appendingPathComponent(imageName)
        return UIImage(contentsOfFile: imageURL.path)
    }
    
    static func deleteImageFromDocumentDirectory(imageName: String) {
        let documentDirectory = RealmManager.getUrl()
        let imageURL = documentDirectory.appendingPathComponent(imageName)
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            do {
                try FileManager.default.removeItem(at: imageURL)
                print("이미지 삭제 완료")
            } catch {
                print("이미지를 삭제하지 못했습니다.")
            }
        }
    }
}
