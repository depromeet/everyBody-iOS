//
//  UIViewController+ToastView.swift
//  Noonbody
//
//  Created by 윤예지 on 2021/12/10.
//

import UIKit.UIViewController

import SnapKit

extension UIViewController {
    
    func showToast(type: ToastType) {
        let toastView = ToastView(type: type)
        toastView.alpha = 0
        
        toastView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(44)
        }
        
        UIView.animate(withDuration: 0.3) {
            toastView.alpha = 1
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                toastView.removeFromSuperview()
            }
        }
    }
    
}
