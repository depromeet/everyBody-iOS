//
//  BaseViewController.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/28.
//

import UIKit

import RxSwift
import RxCocoa

class BaseViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        render()
        initNavigationBar()
    }
    
    private func render() {
        view.backgroundColor = .white
    }
    
    private func initNavigationBar() {
        self.navigationController?.initNaviBarWithBackButton()
    }

    private func setupViewHierarchy() {
        
    }
    
    private func setupConstraint() {
        
    }
}
