//
//  NotificationConfig.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/12/03.
//

import Foundation

// MARK: - NotificationConfig
struct NotificationConfig: Codable {
    let monday, tuesday, wednesday, thursday: Bool
    let friday, saturday, sunday: Bool
    let preferredTimeHour, preferredTimeMinute: Int
    let isActivated: Bool

    enum CodingKeys: String, CodingKey {
        case monday, tuesday, wednesday, thursday, friday, saturday, sunday
        case preferredTimeHour = "preferred_time_hour"
        case preferredTimeMinute = "preferred_time_minute"
        case isActivated = "is_activated"
    }
}
