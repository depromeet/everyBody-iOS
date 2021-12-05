//
//  NotificationAPI.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/03.
//

import Foundation

import Moya

enum NotificationAPI: BaseTargetType {
    typealias ResultModel = NotificationConfig
    
    case getNotificationConfig
    case putNotificationConfig(request: NotificationConfig)
}

extension NotificationAPI {
    
    var path: String {
        switch self {
        case .getNotificationConfig:
            return HTTPMethodURL.GET.notification
        case .putNotificationConfig:
            return HTTPMethodURL.PUT.notification
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getNotificationConfig:
            return .get
        case .putNotificationConfig:
            return .put
        }
    }
    
    var task: Task {
        switch self {
        case .getNotificationConfig:
            return .requestPlain
        case .putNotificationConfig(let request):
            return .requestParameters(parameters: ["monday": request.monday,
                                                   "tuesday": request.tuesday,
                                                   "wednesday": request.wednesday,
                                                   "thursday": request.thursday,
                                                   "friday": request.friday,
                                                   "saturday": request.saturday,
                                                   "sunday": request.sunday,
                                                   "preferred_time_hour": request.preferredTimeHour,
                                                   "preferred_time_minute": request.preferredTimeMinute,
                                                   "is_activated": request.isActivated],
                                      encoding: JSONEncoding.default)
        }
    }
    
}
