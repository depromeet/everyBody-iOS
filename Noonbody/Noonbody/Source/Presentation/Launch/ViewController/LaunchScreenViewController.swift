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
    private let migrationLabel = UILabel().then {
        $0.text = "기존 데이터를 마이그레이션중입니다...💪"
        $0.textColor = .white
        $0.font = .nbFont(ofSize: 15, weight: .semibold, type: .pretendard)
        $0.alpha = 0
    }
    private let loadingView = UIActivityIndicatorView().then {
        $0.color = .white
        $0.alpha = 0
        $0.startAnimating()
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
        view.addSubviews(logoImageView, loadingView, migrationLabel)
        
        logoImageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(30)
            $0.top.equalTo(logoImageView.snp.bottom).offset(20)
        }
        
        migrationLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(loadingView.snp.bottom).offset(20)
        }
    }
    
    private func addObserver() {
        if UserManager.userId == nil {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(signUp),
                                                   name: Notification.Name("setFcmToken"),
                                                   object: nil)
            setDefaultAlbum()
        } else {
            checkDownloadCompleted()
        }
    }
    
    private func setDefaultAlbum() {
        let path = RealmManager.getUrl().appendingPathComponent("default.realm")
        if !FileManager.default.fileExists(atPath: path.path) {
            let album = Album(id: 1, name: "눈바디", thumbnailURL: nil, createdAt: "", albumDescription: "",
                              pictures: Pictures(lower: [], upper: [], whole: []))
            RealmMigrationService.migrateAlbums(albums: [album])
        }
    }
    
    private func checkDownloadCompleted() {
        MyPageService.shared.getMyPage { response in
            switch response {
            case .success(let data):
                if let data = data {
                    if data.downloadCompleted == nil {
                        self.migrationLabel.alpha = 1
                        self.loadingView.alpha = 1
                        self.migration()
                    } else {
                        self.migrationLabel.alpha = 0
                        self.loadingView.alpha = 0
                        self.pushToHomeViewController()
                    }
                }
            case .failure(let err):
                print(err)
            }
        }
    }
    
    private func migration() {
        AlbumService.shared.getAlbumList { response in
            switch response {
            case .success(let data):
                if let data = data {
                    RealmMigrationService.migrateAlbums(albums: data)
                    self.completeDownload()
                }
            case .failure(let err):
                print(err)
            }
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
        AuthService.shared.postSignUp(request: SignUpRequestModel(password: uuid,
                                                                  device: Device(deviceToken: fcmToken,
                                                                                 pushToken: fcmToken))) { response in
            switch response {
            case .success(let data):
                if let data = data {
                    UserManager.userId = data.id
                    UserManager.nickname = data.nickname
                    UserManager.motto = data.motto
                    UserManager.profile = data.profileImage
                    self.requestSignIn()
                }
            case .failure(let err):
                print(err)
            }
        }
    }
    
    private func requestSignIn() {
        guard let userId = UserManager.userId else { return }
        AuthService.shared.postSignIn(request: SignInRequestModel(userId: userId,
                                                                  password: uuid)) { response in
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
    
    private func completeDownload() {
        MyPageService.shared.putDownloadCompleted { response in
            switch response {
            case .success:
                self.pushToHomeViewController()
            case .failure(let err):
                print(err)
            }
        }
    }
}
