//
//  RealmAlbumRepository.swift
//  Noonbody
//
//  Created by kong on 2022/03/18.
//

import Foundation

import RealmSwift
import RxSwift

class LocalAlbumRepositry: AlbumRepository {
    func albums() -> Observable<[Album]> {
        let observable = Observable<[Album]>.create { observer -> Disposable in
            let albums = RealmManager.realm()?.objects(RMAlbum.self).map { $0.asEntity() }
            observer.onNext(albums?.reversed() ?? [])
            return Disposables.create()
        }
        return observable
    }
    
    func album(albumId: Int) -> Observable<Album> {
        let observable = Observable<Album>.create { observer -> Disposable in
            let result = RealmManager.realm()?.objects(RMAlbum.self).filter("id == \(albumId)").first
            observer.onNext(result!.asEntity())
            return Disposables.create()
        }
        return observable
    }
    
    func create(request: AlbumRequestModel) -> Observable<Album> {
        let observable = Observable<Album>.create { observer -> Disposable in
            let album = RMAlbum(name: request.name, createdAt: Date())
            RealmManager.saveObjects(objs: album)
            observer.onNext(album.asEntity())
            return Disposables.create()
        }
        return observable
    }
    
    func create(album: AlbumRequestModel) -> Observable<Int> {
        return Observable<Int>.create { observer -> Disposable in
            let album = RMAlbum(name: album.name, createdAt: Date())
            RealmManager.saveObjects(objs: album)
            observer.onNext(200)
            return Disposables.create()
        }
    }
    
    func delete(albumId: Int) -> Observable<Int> {
        Observable<Int>.create { observer -> Disposable in
            if let album = RealmManager.realm()?.objects(RMAlbum.self).filter("id == \(albumId)").first {
                do {
                    try RealmManager.realm()?.write {
                        RealmManager.realm()?.delete(album)
                        observer.onNext(204)
                    }
                } catch let err {
                    print(err)
                }
            }
            return Disposables.create()
        }
    }
    
    func rename(albumId: Int, request: AlbumRequestModel) -> Observable<RenamedAlbum> {
        let observable = Observable<RenamedAlbum>.create { observer -> Disposable in
            let album = RealmManager.realm()?.objects(RMAlbum.self).filter("id == \(albumId)").first
            do {
                try RealmManager.realm()?.write {
                    album?.name = request.name
                    observer.onNext(RenamedAlbum(name: request.name))
                }
            } catch let err {
                print(err)
            }
            return Disposables.create()
        }
        return observable
    }
    
    func savePhoto(request: PhotoRequestModel) -> Observable<Int> {
        return Observable<Int>.create { observer -> Disposable in
            let fileManager = FileManager()
            let documentURL = RealmManager.getUrl()
            let task = Picture(date: request.takenAt)
            let fileExtension = FileExtension.png
            
            let directoryURL = documentURL.appendingPathComponent("\(request.albumId)/\(request.bodyPart)")
            let imageURL = directoryURL.appendingPathComponent("\(task.id).\(fileExtension)")
            
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch let err {
                print(err.localizedDescription)
            }
            
            guard let data = request.image.pngData() else {
                print("압축에 실패했습니다.")
                return Disposables.create()
            }
            
            do {
                try data.write(to: imageURL)
                try RealmManager.realm()?.write {
                    let localAlbum = RealmManager.realm()?.objects(RMAlbum.self).filter("id==\(request.albumId)").first
                    switch request.bodyPart {
                    case "whole":
                        localAlbum?.whole.append(task)
                    case "upper":
                        localAlbum?.upper.append(task)
                    case "lower":
                        localAlbum?.lower.append(task)
                    default: break
                    }
                }
                
                RealmManager.saveObjects(objs: task)
                observer.onNext(200)
                print("이미지를 저장했습니다")
            } catch {
                print("이미지를 저장하지 못했습니다.")
            }
            
            return Disposables.create()
        }
    }
}
