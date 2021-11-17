//
//  UIViewController+hideKeyboard.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/17.
//

import UIKit

extension UIViewController {
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                  action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
