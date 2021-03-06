//
//  PreferenceDataType.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import Foundation

enum ProfileDataType: Equatable {
    case nickName(nickname: String)
    case motto(motto: String)
    case pushNotification
    case saved
    case privacyPolicy
    
    var title: String {
        switch self {
        case .nickName:
            return "닉네임"
        case .motto:
            return "좌우명"
        case .pushNotification:
            return "알림 설정"
        case .saved:
            return "앱에만 저장"
        case .privacyPolicy:
            return "개인정보 처리방침"
        }
    }
}
