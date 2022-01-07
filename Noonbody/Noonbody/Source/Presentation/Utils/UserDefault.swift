//
//  UserDefault.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/01/06.
//

import Foundation

@propertyWrapper
struct UserDefault<T> {
    
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: self.key) as? T ?? self.defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: self.key)
        }
    }
    
}
