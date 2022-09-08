//
//  UserManager.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/06.
//

import Foundation

class UserManager {
    
    @UserDefault(key: Constant.UserDefault.id, defaultValue: nil)
    static var userId: Int?
    
    @UserDefault(key: Constant.UserDefault.motto, defaultValue: "천천히 그리고 꾸준히!")
    static var motto: String
    
    @UserDefault(key: Constant.UserDefault.nickname, defaultValue: nil)
    static var nickname: String?
    
    @UserDefault(key: Constant.UserDefault.profile, defaultValue: nil)
    static var profile: String?
    
    @UserDefault(key: Constant.UserDefault.hideThumbnail, defaultValue: false)
    static var hideThumbnail: Bool
    
    @UserDefault(key: Constant.UserDefault.biometricAuthentication, defaultValue: false)
    static var biometricAuthentication: Bool
    
    @UserDefault(key: Constant.UserDefault.token, defaultValue: nil)
    static var token: String?
    
    @UserDefault(key: Constant.UserDefault.saveBuiltInLibrary, defaultValue: false)
    static var saveBulitInInLibrary: Bool
    
    @UserDefault(key: Constant.UserDefault.gridMode, defaultValue: true)
    static var gridMode: Bool
    
    @UserDefault(key: Constant.UserDefault.weightMode, defaultValue: false)
    static var weightMode: Bool
    
    @UserDefault(key: Constant.UserDefault.weight, defaultValue: 50)
    static var weight: Int
    
    @UserDefault(key: Constant.UserDefault.demicalWeight, defaultValue: 0)
    static var demicalWeight: Int
    
}
