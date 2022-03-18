//
//  RealmAlbumRepository.swift
//  Noonbody
//
//  Created by kong on 2022/03/18.
//

import Foundation

import RxSwift

class LocalAlbumRepositry: AlbumRepository {
    func albums() -> Observable<[Album]> {
        let observable = Observable<[Album]>.create { observer -> Disposable in
            let result = RealmManager.realm()?.objects(RMAlbums.self).first?.localAlbumArray
            observer.onNext(result ?? [])
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
            let requestReference: () = CreateAlbumService.shared.postCreateAlbum(request: request) { response in
                switch response {
                case .success(let data):
                    if let data = data {
                        observer.onNext(data)
                    }
                case .failure(let err):
                    print(err)
                }
            }
            return Disposables.create(with: { requestReference })
        }
        return observable
    }
    
    func create(album: AlbumRequestModel) -> Observable<Int> {
        return Observable<Int>.create { observer -> Disposable in
            let requestReference: () = CreateAlbumService.shared.postCreateAlbum(request: album) { response in
                switch response {
                case .success:
                    observer.onNext(200)
                case .failure(let err):
                    observer.onError(err)
                }
            }
            return Disposables.create(with: { requestReference })
        }
    }
    
    func delete(albumId: Int) -> Observable<Int> {
        Observable<Int>.create { observer -> Disposable in
            let requestReference: () = PanoramaService.shared.deleteAlbum(id: albumId) { response in
                switch response {
                case .success(let statusCode):
                    if let statusCode = statusCode {
                        observer.onNext(statusCode)
                    }
                case .failure(let err):
                    print(err)
                }
            }
            return Disposables.create(with: { requestReference })
        }
    }
    
    func rename(albumId: Int, request: AlbumRequestModel) -> Observable<RenamedAlbum> {
        let observable = Observable<RenamedAlbum>.create { observer -> Disposable in
            let requestReference: () = PanoramaService.shared.renameAlbum(id: albumId, request: request) { response in
                switch response {
                case .success(let data):
                    if let data = data {
                        observer.onNext(data)
                    }
                case .failure(let err):
                    print(err)
                }
            }
            return Disposables.create(with: { requestReference })
        }
        return observable
    }
    
    func savePhoto(request: PhotoRequestModel) -> Observable<Int> {
        return Observable<Int>.create { observer -> Disposable in
            let fileManager = FileManager()
            let documentURL = RealmManager.getUrl()
            let task = Picture(date: request.takenAt)
            
            let directoryURL = documentURL.appendingPathComponent("\(request.albumId)/\(request.bodyPart)")
            let imageURL = directoryURL.appendingPathComponent("\(task.id).png")
            
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
