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
            setDefaultAlbum()
        } else {
            checkDownloadComleted()
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
    
    private func checkDownloadComleted() {
        MyPageService.shared.getMyPage { response in
            switch response {
            case .success(let data):
                if let data = data {
                    data.downloadCompleted == nil ? self.migration() : self.pushToHomeViewController()
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
                    _ = data.map { RealmMigrationService.migratePictures(album: $0) }
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
            case .success(_):
                self.pushToHomeViewController()
            case .failure(let err):
                print(err)
            }
        }
    }
}
