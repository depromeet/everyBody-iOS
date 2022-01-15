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
    
    struct Input {
        let backingButtonControlEvent: ControlEvent<Void>
    }
    
    struct Output {
        let restoredImageList: Driver<[ImageInfo]>
    }

    var imageList: [ImageInfo]
    var backingList: [(image: ImageInfo, index: Int)] = []
    
    init(imageList: [ImageInfo]) {
        self.imageList = imageList
    }
    
    func transform(input: Input) -> Output {
        let backingStore: BehaviorSubject<[ImageInfo]> = BehaviorSubject(value: imageList)
        
        _ = input.backingButtonControlEvent
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                guard let deletedItem = owner.backingList.popLast() else { return }
                owner.imageList.insert(deletedItem.image, at: deletedItem.index)
                backingStore.onNext(owner.imageList)
            })
        
        return Output(restoredImageList: backingStore.asDriver(onErrorJustReturn: []))
    }
    
    func deleteButtonDidTap(identifier: ImageInfo) -> Int? {
        guard let index = imageList.firstIndex(where: {
            item in item.imageKey == identifier.imageKey
        }) else { return nil }
        
        backingList.append((imageList[index], index))
        imageList.remove(at: index)
        
        return index
    }
}
