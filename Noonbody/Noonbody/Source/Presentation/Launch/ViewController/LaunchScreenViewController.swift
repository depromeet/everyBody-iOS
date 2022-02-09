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
        if UserManager.userId == nil {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(signUp),
                                                   name: Notification.Name("setFcmToken"),
                                                   object: nil)
        } else {
            pushToHomeViewController()
        }
    }
    
    @objc
    private func signUp(notification: NSNotification) {
        if let fcmToken = notification.object as? String {
            requestSignUp(fcmToken: fcmToken)
        }
    }
    
    private func pushToHomeViewController() {
        let homeViewController = HomeViewController()
        self.navigationController?.pushViewController(homeViewController, animated: false)
    }
    
    private func requestSignUp(fcmToken: String) {
        AuthService.shared.postSignUp(request: SignUpRequestModel(password: fcmToken,
                                                                  device: Device(deviceToken: fcmToken,
                                                                                 pushToken: fcmToken))) { response in
            switch response {
            case .success(let data):
                if let data = data {
                    UserManager.userId = data.id
                    UserManager.nickname = data.nickname
                    UserManager.motto = data.motto
                    UserManager.profile = data.profileImage
                    self.requestSignIn(fcmToken: fcmToken)
                }
            case .failure(let err):
                print(err)
            }
        }
        
    }
    
    private func requestSignIn(fcmToken: String) {
        guard let userId = UserManager.userId else { return }
        AuthService.shared.postSignIn(request: SignInRequestModel(userId: userId,
                                                                  password: fcmToken)) { response in
            switch response {
            case .success(let data):
                if let data = data {
                    UserManager.token = data.accessToken
                }
                self.pushToHomeViewController()
            case .failure(let err):
                print(err)
            }
        }
    }
}
