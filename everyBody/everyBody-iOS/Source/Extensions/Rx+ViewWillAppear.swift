//
//  Rx+ViewWillAppear.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import UIKit

import RxSwift

extension RxSwift.Reactive where Base: UIViewController {
    public var viewWillAppear: Observable<Bool> {
        return methodInvoked(#selector(UIViewController.viewWillAppear))
            .map { $0.first as? Bool ?? false }
    }
}
