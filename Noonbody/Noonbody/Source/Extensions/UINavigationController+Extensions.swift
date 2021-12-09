//
//  UINavigationController+Extensions.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/13.
//

import UIKit
import SwiftUI

extension UINavigationController {
    
    func initNaviBarWithBackButton() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
        self.navigationBar.tintColor = .black
    }
    
    func initNavigationBar(navigationItem: UINavigationItem?,
                           leftButtonImages: [UIImage]? = nil,
                           rightButtonImages: [UIImage]? = nil,
                           leftActions: [Selector]? = nil,
                           rightActions: [Selector]? = nil) {
        
        initNaviBarWithBackButton()
        
        makeBarButtons(navigationItem: navigationItem,
                       buttonImage: leftButtonImages,
                       actions: leftActions,
                       isLeft: true)
        
        makeBarButtons(navigationItem: navigationItem,
                       buttonImage: rightButtonImages,
                       actions: rightActions,
                       isLeft: false)
        
        let backBarButtton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem?.backBarButtonItem = backBarButtton
    }
    
    func makeBarButtons(navigationItem: UINavigationItem?,
                        buttonImage: [UIImage]?,
                        actions: [Selector]?,
                        isLeft: Bool
    ) {
        guard let buttonImage = buttonImage,
              let actions = actions else { return }
        
        var barButtonItems: [UIBarButtonItem] = []
        buttonImage.enumerated().forEach { index, image in
            guard let button = navigationItem?.makeCustomBarItem(self.topViewController,
                                                                 action: actions[index],
                                                                 image: image) else { return }
            barButtonItems.append(button)
        }
        
        if isLeft {
            navigationItem?.leftBarButtonItems = barButtonItems
        } else {
            navigationItem?.rightBarButtonItems = barButtonItems
        }
    }
    
}
