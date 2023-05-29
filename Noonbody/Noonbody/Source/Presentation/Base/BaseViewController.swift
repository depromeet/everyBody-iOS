//
//  BaseViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/28.
//

import UIKit

import RxSwift
import RxCocoa
import Mixpanel

class BaseViewController: UIViewController {

    let disposeBag = DisposeBag()
    var isPushed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        render()
        initNavigationBar()
    }
    
    func render() {
        view.backgroundColor = Asset.Color.Background.default.color
    }
    
    private func initNavigationBar() {
        self.navigationController?.initNaviBarWithBackButton()
    }

}
