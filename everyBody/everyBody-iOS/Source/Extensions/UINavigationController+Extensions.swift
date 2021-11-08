//
//  UINavigationController+Extensions.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/10/13.
//

import UIKit

extension UINavigationController {
    
    /// 투명한 네비게이션 바
    
    func initTransparentNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
    }
    
    /// 뒤로가기 버튼이 있는 네비게이션 바
    
    func initNaviBarWithBackButton() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.initBackButtonAppearance()
        
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
        self.navigationBar.tintColor = .black
    }
    
    func initWithRightBarButton(navigationItem: UINavigationItem?, rightButtonImage: UIImage, action: Selector) {
        initNaviBarWithBackButton()
        
        let rightBarButton = UIBarButtonItem(image: rightButtonImage, style: .plain, target: self.topViewController, action: action)
        navigationItem?.rightBarButtonItem = rightBarButton
    }
    
    /// 오른쪽에 버튼이 두개인 네비게이션 바
    func initWithRightBarTwoButtons(navigationItem: UINavigationItem?, rightButtonImage: [UIImage], action: [Selector]) {
        initNaviBarWithBackButton()
        
        let rightBarFirstButton = UIBarButtonItem(image: rightButtonImage[0], style: .plain, target: self.topViewController, action: action[0])
        let rightBarSecondButton = UIBarButtonItem(image: rightButtonImage[1], style: .plain, target: self.topViewController, action: action[1])
        
        navigationItem?.rightBarButtonItems = [rightBarFirstButton,rightBarSecondButton]
    }

}

extension UINavigationBarAppearance {
    
    func initBackButtonAppearance() {
        var backButtonImage: UIImage? {
            return Asset.Image.back.image
        }
        
        var backButtonAppearance: UIBarButtonItemAppearance {
            let backButtonAppearance = UIBarButtonItemAppearance()
            backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear, .font: UIFont.systemFont(ofSize: 0.0)]

            return backButtonAppearance
        }
        
        self.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
        self.backButtonAppearance = backButtonAppearance
    }
}
