//
//  Rx+PreviewCollectionViewCell.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/16.
//

import UIKit

import RxCocoa
import RxSwift


class RxCollectionViewCellDelegateProxy: DelegateProxy<PreviewCollectionViewCell, DeleteButtonDelegate>, DelegateProxyType, DeleteButtonDelegate {
    
    static func registerKnownImplementations() {
        self.register { button in
            RxCollectionViewCellDelegateProxy(parentObject: button,
                                              delegateProxy: self)
        }
    }
    
    static func currentDelegate(for object: PreviewCollectionViewCell) -> DeleteButtonDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: DeleteButtonDelegate?, to object: PreviewCollectionViewCell) {
        object.delegate = delegate
    }
        
}

extension Reactive where Base: PreviewCollectionViewCell {
    var delegate: DelegateProxy<PreviewCollectionViewCell, DeleteButtonDelegate> {
        return RxCollectionViewCellDelegateProxy.proxy(for: self.base)
    }

    var deleteButtonDelegate: Observable<ImageInfo> {
        return delegate
            .methodInvoked(#selector(DeleteButtonDelegate.deleteButtonDidTap(_:cellIdentifier:)))
            .map({ parameters in
                return parameters[1] as? ImageInfo ?? ImageInfo(imageKey: "", imageURL: "")
            })
    }
}
