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
        let isSaved: Driver<Bool>
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
            .flatMap { () -> Observable<Bool> in
                let settings = RenderSettings()
                let imageAnimator = ImageAnimator(renderSettings: settings)
                imageAnimator.images = self.imagePaths.map { AlbumManager.loadImageFromDocumentDirectory(from: $0) ?? UIImage() }
                var isSave = true
                imageAnimator.render { save in
                    isSave = save
                }
                return Observable.just(isSave)
            }
            .share()
        
        let save = response
            .compactMap { $0 }
            .map { response -> Bool in
                return response
            }.asDriver(onErrorJustReturn: false)
        
        return Output(imageList: backingStore.asDriver(onErrorJustReturn: []),
                      isSaved: save)
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
