//
//  DefaultAlbumRepositry.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/02.
//

import Foundation

import RealmSwift
import RxSwift
import Moya

class DefaultAlbumRepositry: AlbumRepository {
    func getAlbumList() -> Observable<[LocalAlbum]> {
        let observable = Observable<[LocalAlbum]>.create { observer -> Disposable in
            let result = RealmManager.realm()?.objects(LocalAlbums.self).first?.localAlbumArray
            observer.onNext(result ?? [])
            return Disposables.create()
        }
        return observable
    }
    
    func createAlbum(request: AlbumRequestModel) -> Observable<Album> {
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
    
    func createAlbum(request: AlbumRequestModel) -> Observable<Int> {
        return Observable<Int>.create { observer -> Disposable in
            let requestReference: () = CreateAlbumService.shared.postCreateAlbum(request: request) { response in
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
                    let localAlbum = RealmManager.realm()?.objects(LocalAlbum.self).filter("id==\(request.albumId)").first
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
    
    func sendFeedback(request: FeedbackRequestModel) -> Observable<Int> {
        Observable<Int>.create { observer -> Disposable in
            let requestReference: () = AlbumService.shared.sendFeedback(request: request) { response in
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
}
