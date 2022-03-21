//
//  LaunchViewModel.swift
//  Noonbody
//
//  Created by 윤예지 on 2021/12/11.
//

import Foundation

import RealmSwift

// 앱의 첫 실행 여부를 검사하는 클래스

final class LaunchService {
    let wasLaunchedBefore: Bool
    var isFirstLaunch: Bool {
        return !wasLaunchedBefore
    }
    
    init(getWasLaunchedBefore: () -> Bool,
         setWasLaunchedBefore: (Bool) -> Void) {
        let wasLaunchedBefore = getWasLaunchedBefore()
        self.wasLaunchedBefore = wasLaunchedBefore
        if !wasLaunchedBefore {
            setWasLaunchedBefore(true)
            setDefaultAlbum()
        }
    }
    
    convenience init(userDefaults: UserDefaults, key: String) {
        self.init(getWasLaunchedBefore: { userDefaults.bool(forKey: key) },
                  setWasLaunchedBefore: { userDefaults.set($0, forKey: key) })
    }
    
    private func setDefaultAlbum() {
        let album = RMAlbum(name: "눈바디", createdAt: Date())
        RealmManager.saveObjects(objs: album)
    }
}
