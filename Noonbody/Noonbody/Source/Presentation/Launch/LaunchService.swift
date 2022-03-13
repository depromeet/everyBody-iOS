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
    private var realm: Realm!
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
            setDefaultRealmData()
        }
    }
    
    convenience init(userDefaults: UserDefaults, key: String) {
        self.init(getWasLaunchedBefore: { userDefaults.bool(forKey: key) },
                  setWasLaunchedBefore: { userDefaults.set($0, forKey: key) })
    }
    
    private func setDefaultRealmData() {
        let albums = LocalAlbums()
        let album = LocalAlbum(name: "눈바디", createdAt: Date())
        albums.localAlbums.append(album)
        RealmManager.saveObjects(objs: albums)
    }
}
