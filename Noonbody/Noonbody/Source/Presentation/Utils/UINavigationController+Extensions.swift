//
//  UINavigationController+Extensions.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/13.
//

import UIKit
import SwiftUI

extension UINavigationController {
    
    private var backButtonAppearance: UIBarButtonItemAppearance {
        let backButtonAppearance = UIBarButtonItemAppearance()

        backButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.clear,
            .font: UIFont.systemFont(ofSize: 0.0)
        ]

        return backButtonAppearance
    }
    
    private var backButtonImage: UIImage? {
        return Asset.Image.back.image
            .resizeImage(to: CGSize(width: 32, height: 32), point: CGPoint(x: 0, y: 5))
            .withAlignmentRectInsets(
                UIEdgeInsets(
                    top: 20.0,
                    left: -5.0,
                    bottom: 0.0,
                    right: 0.0
                )
            )
    }
    
    func initNaviBarWithBackButton() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: Asset.Color.gray90.color
        ]
        
        appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
        appearance.backButtonAppearance = backButtonAppearance
        
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = Asset.Color.gray90.color
        
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