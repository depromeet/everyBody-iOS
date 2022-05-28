//
//  VideoViewModel.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/15.
//

import Foundation
import UIKit.UIImage

import RxCocoa
import RxSwift

final class VideoViewModel {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let backingButtonControlEvent: ControlEvent<Void>
        let saveButtonControlEvent: ControlEvent<Void>
    }
    
    struct Output {
        let imageList: Driver<[String]>
        let statusCode: Driver<Int>
    }

    var imagePaths: [String]
    var backingList: [(image: String, index: Int)] = []
    var imageSubject = BehaviorSubject<[String]>(value: [])
    let videoUsecase: VideoUseCase
    
    init(images: [String], videoUsecase: VideoUseCase) {
        self.imagePaths = images
        self.videoUsecase = videoUsecase
        imageSubject.onNext(images)
    }
    
    func transform(input: Input) -> Output {
        let backingStore: BehaviorSubject<[String]> = BehaviorSubject(value: imagePaths)
        
        _ = input.backingButtonControlEvent
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                guard let deletedItem = owner.backingList.popLast() else { return }
                owner.imagePaths.insert(deletedItem.image, at: deletedItem.index)
                backingStore.onNext(owner.imagePaths)
                owner.imageSubject.onNext(owner.imagePaths)
            })
            .disposed(by: disposeBag)
        
        let response =
            input.saveButtonControlEvent
            .withLatestFrom(imageSubject)
            .map({ imageList -> VideoRequestModel in
                // TODO: LOCAL UIimage
//                let imageKeys = imageList.map { $0.imageKey }
                return VideoRequestModel(keys: [""])
            })
            .withUnretained(self)
            .flatMap { owner, requestModel -> Observable<Int> in
                // TODO: LOCAL VideoGenerator
                owner.videoUsecase.downloadVideo(imageKeys: requestModel)
            }
            .share()
        
        let statusCode = response
            .compactMap { $0 }
            .map { response -> Int in
                return response
            }.asDriver(onErrorJustReturn: 404)
        
        return Output(imageList: backingStore.asDriver(onErrorJustReturn: []),
                      statusCode: statusCode)
    }
    
    func deleteButtonDidTap(identifier: String) -> Int? {
        guard let index = imagePaths.firstIndex(where: { item in
            item == identifier
        }) else { return nil }
        
        backingList.append((imagePaths[index], index))
        imagePaths.remove(at: index)
        imageSubject.onNext(imagePaths)
        
        return index
    }
}
