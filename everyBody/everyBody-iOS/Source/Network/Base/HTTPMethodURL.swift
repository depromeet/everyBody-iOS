//
//  HTTPMethods.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/26.
//

import Foundation

enum HTTPMethodURL {
    
    struct GET {
        static let userInfo = "/users/me"
        static let notification = "/notification-configs/me"
        static let album = "/albums"
    }
    
    struct POST {
        static let createAlbum = "/albums"
    }
    
    struct PUT {
        static let userInfo = "/users/me"
        static let notification = "/notification-configs/me"
    }
    
    struct DELETE {
        
    }
    
}
