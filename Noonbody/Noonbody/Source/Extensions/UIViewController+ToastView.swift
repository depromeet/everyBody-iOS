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
        self.view.addSubview(toastView)
        toastView.alpha = 0
        
        toastView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(44)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        UIView.animate(withDuration: 0.5) {
            toastView.alpha = 1
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                UIView.animate(withDuration: 0.5) {
                    toastView.alpha = 0
                }
            }
        }
    }
    
}
