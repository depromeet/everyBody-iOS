//
//  LaunchScreenViewController.swift
//  Noonbody
//
//  Created by 윤예지 on 2021/12/11.
//

import UIKit

import Then
import SnapKit

class LaunchScreenViewController: UIViewController {
    
    private let logoImageView = UIImageView().then {
        $0.image = Asset.Image.logo.image
    }
    private let launchService = LaunchService(userDefaults: .standard, key: "user")
    private let uuid = UIDevice.current.identifierForVendor!.uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Asset.Color.keyPurple.color
        setupConstraint()
        addObserver()
    }
    
    private func setupConstraint() {
        view.addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkFirstLaunch),
                                               name: Notification.Name("setFcmToken"),
                                               object: nil)
    }
    
    @objc
    private func checkFirstLaunch(notification: NSNotification) {
        if let fcmToken = notification.object as? String {
            if launchService.isFirstLaunch {
                requestSignUp(fcmToken: fcmToken)
            } else {
                requestSignIn()
            }
        }
    }
    
    private func pushToHomeViewController() {
        let homeViewController = HomeViewController()
        self.navigationController?.pushViewController(homeViewController, animated: false)
    }
    
    private func requestSignUp(fcmToken: String) {
        AuthService.shared.postSignUp(request: SignUpRequestModel(password: uuid,
                                                                  device: Device(deviceToken: fcmToken,
                                                                                 pushToken: fcmToken))) { response in
            switch response {
            case .success(let data):
                if let data = data {
                    UserDefaults.standard.set(data.id, forKey: "id")
                    UserDefaults.standard.set(data.nickname, forKey: "nickname")
                    UserDefaults.standard.set(data.motto, forKey: "motto")
                    UserDefaults.standard.set(data.profileImage, forKey: "profile")
                    self.requestSignIn()
                }
            case .failure(let err):
                print(err)
            }
        }
        
    }
    
    private func requestSignIn() {
        guard let userId = UserDefaults.standard.string(forKey: "id") else { return }
        AuthService.shared.postSignIn(request: SignInRequestModel(userId: userId,
                                                                  password: uuid)) { response in
            switch response {
            case .success(let data):
                if let data = data {
                    UserDefaults.standard.set(data.accessToken, forKey: "token")
                }
                self.pushToHomeViewController()
            case .failure(let err):
                print(err)
            }
        }
    }
}