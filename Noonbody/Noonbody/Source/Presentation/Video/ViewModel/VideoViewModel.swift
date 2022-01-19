//
//  VideoViewModel.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/15.
//

import Foundation

import RxCocoa
import RxSwift

final class VideoViewModel {
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let backingButtonControlEvent: ControlEvent<Void>
        let saveButtonControlEvent: ControlEvent<Void>
    }
    
    struct Output {
        let restoredImageList: Driver<[ImageInfo]>
        let statusCode: Driver<Int>
    }

    var imageList: [ImageInfo]
    var backingList: [(image: ImageInfo, index: Int)] = []
    var imageSubject = PublishSubject<[ImageInfo]>()
    let videoUsecase: VideoUseCase
    
    init(imageList: [ImageInfo], videoUsecase: VideoUseCase) {
        self.imageList = imageList
        self.videoUsecase = videoUsecase
        imageSubject.onNext(imageList)
    }
    
    func transform(input: Input) -> Output {
        let backingStore: BehaviorSubject<[ImageInfo]> = BehaviorSubject(value: imageList)
        
        _ = input.backingButtonControlEvent
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                guard let deletedItem = owner.backingList.popLast() else { return }
                owner.imageList.insert(deletedItem.image, at: deletedItem.index)
                backingStore.onNext(owner.imageList)
                owner.imageSubject.onNext(owner.imageList)
            })
            .disposed(by: disposeBag)
        
        let response =
            input.saveButtonControlEvent
            .withLatestFrom(imageSubject)
            .map({ imageList in
                let imageKeys = imageList.map { $0.imageKey }
                return VideoRequestModel(keys: imageKeys)
            })
            .withUnretained(self)
            .flatMap { owner, requestModel -> Observable<Int> in
                owner.videoUsecase.downloadVideo(imageKeys: requestModel)
            }
            .share()
        
        let statusCode = response
            .compactMap { $0 }
            .map { response -> Int in
                return response
            }.asDriver(onErrorJustReturn: 404)
        
        return Output(restoredImageList: backingStore.asDriver(onErrorJustReturn: []),
                      statusCode: statusCode)
    }
    
    func deleteButtonDidTap(identifier: ImageInfo) -> Int? {
        guard let index = imageList.firstIndex(where: { item in
            item.imageKey == identifier.imageKey
        }) else { return nil }
        
        backingList.append((imageList[index], index))
        imageList.remove(at: index)
        imageSubject.onNext(imageList)
        
        return index
    }
}
