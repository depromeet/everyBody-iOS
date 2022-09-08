//
//  PreferenceDataType.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/21.
//

import Foundation

enum ProfileDataType: Equatable {
    case motto(motto: String)
//    case pushNotification
    case saved
    case hideThumbnail
    case biometricAuthentication
    case privacyPolicy
    
    var title: String {
        switch self {
        case .motto:
            return "좌우명"
//        case .pushNotification:
//            return "알림 설정"
        case .saved:
            return "앱에만 저장"
        case .hideThumbnail:
            return "썸네일 가리기"
        case .biometricAuthentication:
            return "생체 인증"
        case .privacyPolicy:
            return "개인정보 처리방침"
        }
    }
}
