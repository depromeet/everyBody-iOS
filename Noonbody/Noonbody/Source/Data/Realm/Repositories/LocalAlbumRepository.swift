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
}
