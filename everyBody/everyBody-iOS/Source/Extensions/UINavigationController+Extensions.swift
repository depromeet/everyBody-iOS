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
        appearance.configureWithOpaqueBackground()
        appearance.initBackButtonAppearance()
        appearance.backgroundColor = .white
        
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
        self.navigationBar.tintColor = .black
    }
    
    func initNaviBarWithCloseButton(navigationItem: UINavigationItem?, rightButtonImage: UIImage, action: Selector, closeAction: Selector) {
        let closeButton = UIBarButtonItem(image: Asset.Image.clear.image, style: .plain, target: self.topViewController, action: closeAction)
        let rightBarButton = UIBarButtonItem(image: rightButtonImage, style: .plain, target: self.topViewController, action: action)
        navigationItem?.leftBarButtonItem = closeButton
        navigationItem?.rightBarButtonItems = [rightBarButton]
    }
    
    func initWithRightBarButton(navigationItem: UINavigationItem?, rightButtonImage: UIImage, action: Selector) {
        initNaviBarWithBackButton()
        
        let rightBarButton = UIBarButtonItem(image: rightButtonImage, style: .plain, target: self.topViewController, action: action)
        navigationItem?.rightBarButtonItem = rightBarButton
    }
    
    /// 오른쪽에 버튼이 두개인 네비게이션 바
    func initWithRightBarTwoButtons(navigationItem: UINavigationItem?, rightButtonImage: [UIImage], action: [Selector]) {
        print("initWithRightBarTwoButtons")
        initNaviBarWithBackButton()
        
        /// 코드 반복문으로 바꿔야겟다
        guard let rightBarFirstButton = navigationItem?.makeCustomBarItem(self.topViewController, action: action[0], image: rightButtonImage[0]) else { return }
        guard let rightBarSecondButton = navigationItem?.makeCustomBarItem(self.topViewController, action: action[1], image: rightButtonImage[1]) else { return }
        navigationItem?.leftBarButtonItem = nil
        navigationItem?.rightBarButtonItems = [rightBarFirstButton, rightBarSecondButton]
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
