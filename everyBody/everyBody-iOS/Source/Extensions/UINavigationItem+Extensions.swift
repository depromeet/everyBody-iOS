//
//  UINavigationItem+Extensions.swift
//  everyBody-iOS
//
//  Created by kong on 2021/11/20.
//

import UIKit

extension UINavigationItem {
    func makeCustomBarItem(_ target: Any?, action: Selector, image: UIImage) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 26).isActive = true
        barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 26).isActive = true
        
        return barButtonItem
    }
}
