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
        static let photo = "/pictures"
        static let signUp = "/auth/signup"
        static let singIn = "/auth/login"
        static let video = "/videos/download"
        static let feedback = "/feedbacks"
    }
    
    struct PUT {
        static let userInfo = "/users/me"
        static let notification = "/notification-configs/me"
        static let album = "/albums"
    }
    
    struct DELETE {
        static let pictures = "/pictures"
        static let album = "/albums"
    }
    
}
