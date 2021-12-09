//
//  NotificationService.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/03.
//

import Foundation

import Moya

public class NotificationService {

    static let shared = NotificationService()
    let provider = MultiMoyaProvider()
    
    private init() { }
    
    func getNotificationConfig(completion: @escaping (Result<NotificationConfig?, Error>) -> Void) {
        provider.requestDecoded(NotificationAPI.getNotificationConfig) { response in
            completion(response)
        }
    }
    
    func putNotificationConfig(request: NotificationConfig, completion: @escaping (Result<Int?, Error>) -> Void) {
        provider.requestNoResultAPI(NotificationAPI.putNotificationConfig(request: request)) { response in
            completion(response)
        }
    }
}
