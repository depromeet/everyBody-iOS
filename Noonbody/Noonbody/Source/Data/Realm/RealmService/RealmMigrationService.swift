//
//  RealmMigrationService.swift
//  Noonbody
//
//  Created by kong on 2022/05/28.
//

import UIKit

import RealmSwift

public class RealmMigrationService {
    static func migrateAlbums(albums: Albums) {
        albums.forEach ({ album in
            let albumObject = RMAlbum(name: album.name, createdAt: Date())
            let directoryURL = RealmManager.getUrl().appendingPathComponent("\(albumObject.id)")
            do {
                try FileManager().createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                RealmManager.saveObjects(objs: albumObject)
            } catch let err {
                print(err.localizedDescription)
            }
        })
    }
    
    static func migratePictures(album: Album) {
        guard let realm = RealmManager.realm() else { return }
        let documentURL = RealmManager.getUrl()
        let fileManager = FileManager()
        let bodyParts = [album.pictures.whole, album.pictures.upper, album.pictures.lower]
        
        bodyParts.flatMap { $0 }
        .map { picture -> PictureRequestModel in
            let url = URL(string: picture.imageURL)!
            let data = try? Data(contentsOf: url)
            let image = UIImage(data: data!)!
            
            return PictureRequestModel(image: image,
                                       albumId: album.id,
                                       bodyPart: picture.bodyPart,
                                       takenAt: picture.takenAt)
        }.forEach({ picture in
            let pictureObject = Picture(albumId: picture.albumId,
                                        bodyPart: "\(picture.bodyPart)",
                                        directoryURL: "\(picture.albumId)/\(picture.bodyPart)",
                                        date: picture.takenAt)
            let directoryURL = documentURL.appendingPathComponent(pictureObject.directoryURL)
            let imageURL = directoryURL.appendingPathComponent("\(album.id).\(FileExtension.png)")
            let data = picture.image.pngData()!
            
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                try data.write(to: imageURL)
                try realm.write {
                    let localAlbum = realm.objects(RMAlbum.self).filter("id == \(album.id)").first
                    switch picture.bodyPart {
                    case .whole:
                        localAlbum?.whole.append(pictureObject)
                    case .upper:
                        localAlbum?.upper.append(pictureObject)
                    case .lower:
                        localAlbum?.lower.append(pictureObject)
                    }
                }
                RealmManager.saveObjects(objs: pictureObject)
            } catch let err {
                print(err.localizedDescription)
            }
        })
    }
}
