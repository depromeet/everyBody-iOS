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
            let directoryURL = RealmManager.getUrl().appendingPathComponent("\(album.id)")
            do {
                try FileManager().createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                RealmManager.saveObjects(objs: album)
                observer.onNext(album.asEntity())
            } catch let err {
                print(err.localizedDescription)
            }
            return Disposables.create()
        }
        return observable
    }
    
    func create(album: AlbumRequestModel) -> Observable<Int> {
        return Observable<Int>.create { observer -> Disposable in
            let album = RMAlbum(name: album.name, createdAt: Date())
            let directoryURL = RealmManager.getUrl().appendingPathComponent("\(album.id)")
            do {
                try FileManager().createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                RealmManager.saveObjects(objs: album)
                observer.onNext(200)
            } catch let err {
                print(err.localizedDescription)
            }
            return Disposables.create()
        }
    }
    
    func delete(albumId: Int) -> Observable<Int> {
        Observable<Int>.create { observer -> Disposable in
            let documentDirectory = RealmManager.getUrl()
            if let album = RealmManager.realm()?.objects(RMAlbum.self).filter("id == \(albumId)").first,
               let pictures = RealmManager.realm()?.objects(Picture.self).filter("albumId == \(albumId)") {
                do {
                    let albumURL = documentDirectory.appendingPathComponent("\(albumId)")
                    try RealmManager.realm()?.write {
                        RealmManager.realm()?.delete(album)
                        RealmManager.realm()?.delete(pictures)
                        try FileManager.default.removeItem(at: albumURL)
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
}
