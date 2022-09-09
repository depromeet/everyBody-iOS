//
//  SceneDelegate.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/09/22.
//

import UIKit

import Siren

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appSwitcherModeImageView = UIImageView()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        let siren = Siren.shared
        siren.presentationManager = PresentationManager(
          appName: "Noonbody",
          alertTitle: "업데이트 해주세요!",
          alertMessage: "좀 더 나은 눈바디가 되기 위해 노력했어요 :)",
          updateButtonTitle: "업데이트 하러가기",
          forceLanguageLocalization: .korean
        )
        siren.rulesManager = RulesManager(globalRules: .critical)
        siren.apiManager = APIManager(country: .korea) // 기준 위치 대한민국 앱스토어로 변경
        siren.wail(performCheck: .onDemand) { _ in }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .white
        let rootViewController = LaunchScreenViewController()
        window?.rootViewController = UINavigationController(rootViewController: rootViewController)
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        appSwitcherModeImageView.removeFromSuperview()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        if UserManager.biometricAuthentication {
            setupAppSwitcherMode()
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        if UserManager.biometricAuthentication {
            switch scene.activationState {
            case .background: // 한번 백그라운드에 갔다온 경우, 다시 생체인증 요구
                evaluateAuthentication()
            default:
                break
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

}

extension SceneDelegate {
    
    private func evaluateAuthentication() {
        LocalAuthenticationService.shared.evaluateAuthentication { response, error in
            DispatchQueue.main.async {
                if response {
                    self.window?.rootViewController?.presentedViewController?.dismiss(animated: false)
                } else if error != nil {
                    let popUp = AuthenticationPopupViewController()
                    popUp.delegate = self
                    popUp.modalTransitionStyle = .crossDissolve
                    popUp.modalPresentationStyle = .overFullScreen
                    self.window?.rootViewController?.present(popUp, animated: false)
                }
            }
        }
    }
    
    private func setupAppSwitcherMode() {
        guard let window = window else { return }
        appSwitcherModeImageView = UIImageView(frame: window.frame)
        appSwitcherModeImageView.image = Asset.Image.logo.image
        appSwitcherModeImageView.contentMode = .center
        appSwitcherModeImageView.backgroundColor = Asset.Color.keyPurple.color
        window.addSubview(appSwitcherModeImageView)
    }
    
}

extension SceneDelegate: PopUpActionProtocol {
    
    func cancelButtonDidTap(_ button: UIButton) {
        LocalAuthenticationService.shared.evaluateAuthentication { response, _ in
            DispatchQueue.main.async {
                if response {
                    self.window?.rootViewController?.presentedViewController?.dismiss(animated: false)
                }
            }
        }
    }
    
}
