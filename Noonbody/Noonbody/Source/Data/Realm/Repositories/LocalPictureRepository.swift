//
//  LocalPictureRepository.swift
//  Noonbody
//
//  Created by kong on 2022/03/25.
//

import Foundation

import RealmSwift
import RxSwift

class LocalPictureRepository: PictureRepository {
    func save(request: PictureRequestModel) -> Observable<Int> {
        return Observable<Int>.create { observer -> Disposable in
            let fileManager = FileManager()
            let documentURL = RealmManager.getUrl()
            let task = Picture(albumId: request.albumId,
                               bodyPart: request.bodyPart,
                               directoryURL: "\(request.albumId)/\(request.bodyPart)",
                               date: request.takenAt)
            
            let directoryURL = documentURL.appendingPathComponent(task.directoryURL)
            let imageURL = directoryURL.appendingPathComponent("\(task.id).\(FileExtension.png)")
            
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch let err {
                print(err.localizedDescription)
            }
            
            guard let data = request.image.pngData() else {
                return Disposables.create()
            }
            
            do {
                try data.write(to: imageURL)
                try realm.write {
                    let localAlbum = realm.objects(RMAlbum.self).filter("id == \(request.albumId)").first
                    switch request.bodyPart {
                    case .whole:
                        localAlbum?.whole.append(picture)
                    case .upper:
                        localAlbum?.upper.append(picture)
                    case .lower:
                        localAlbum?.lower.append(picture)
                    }
                }
                RealmManager.saveObjects(objs: picture)
                observer.onNext(200)
            } catch {
                
            }
            
            return Disposables.create()
        }
    }
    
    func delete(pictureId: Int) -> Observable<Int> {
        Observable<Int>.create { observer -> Disposable in
            let documentDirectory = RealmManager.getUrl()
            if let picture = RealmManager.realm()?.objects(Picture.self).filter("id==\(pictureId)").first {
                
                let imageURL = documentDirectory.appendingPathComponent("\(picture.directoryURL)/\(pictureId).\(FileExtension.png)")
                
                do {
                    try RealmManager.realm()?.write {
                        RealmManager.realm()?.delete(picture)
                        try FileManager.default.removeItem(at: imageURL)
                        observer.onNext(200)
                    }
                } catch {
                    
                }
            }
            return Disposables.create()
        }
    }
}
