//
//  UINavigationItem+Extensions.swift
//  everyBody-iOS
//
//  Created by kong on 2021/11/20.
//

import UIKit

extension UINavigationItem {
    func makeCustomBarItem(_ target: Any?, action: Selector? = nil, image: UIImage, childItem: [UIAction]? = nil) -> UIBarButtonItem {
        
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        
        if let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        
        if let childItem = childItem {
            button.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: childItem)
            button.showsMenuAsPrimaryAction = true
        }
        
        let barButtonItem = UIBarButtonItem(customView: button)
        barButtonItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        barButtonItem.customView?.heightAnchor.constraint(equalToConstant: 32).isActive = true
        barButtonItem.customView?.widthAnchor.constraint(equalToConstant: 32).isActive = true
        
        return barButtonItem
    }
}
