//
//  DateViewModel.swift
//  everyBody-iOS
//
//  Created by 윤예지 on 2021/11/19.
//

import Foundation

import RxSwift

enum Month: Int {
    case jan = 1, feb, mar, apr, may, june, july, aug, sep, oct, nov, dec
    
    func toString() -> String {
        return "\(self)".capitalized
    }
    
    func toNumberMonth() -> String {
        switch self {
        case .jan:
            return "01"
        case .feb:
            return "02"
        case .mar:
            return "03"
        case .apr:
            return "04"
        case .may:
            return "05"
        case .june:
            return "06"
        case .july:
            return "07"
        case .aug:
            return "08"
        case .sep:
            return "09"
        case .oct:
            return "10"
        case .nov:
            return "11"
        case .dec:
            return "12"
        }
    }
}

struct DateViewModel {
    
    private let camera = Camera.shared
    
    let currentDate = AppDate()
    
    var yearList: [String] {
        return (2000...currentDate.getYear()).map {
            String($0)
        }
    }
    
    var monthList: [Month] {
        return [.jan, .feb, .mar, .apr, .may, .june, .july, .aug, .sep, .oct, .nov, .dec]
    }
    
    var dayList: [[String]] {
        return [(1...31).map { String($0) },
                (1...30).map { String($0) },
                (1...29).map { String($0) },
                (1...28).map { String($0) }]
    }
    
    var hourList: [String] {
        return (1...24).map { String($0) }
    }
    
    var minuteList: [String] {
        return (0...59).map { String($0) }
    }

}
