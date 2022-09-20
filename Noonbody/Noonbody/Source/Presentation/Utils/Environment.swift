//
//  Environment.swift
//  Noonbody
//
//  Created by 윤예지 on 2022/09/21.
//

import Foundation

enum Environment: String {
    case testflight = "testflight"
    case production = "production"
    case development = "development"
}

func env() -> Environment {
    // TestFlight
    if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
        return .testflight
    }
    
    #if DEBUG
        return .development
    #else
    // AppStore
        return .production
    #endif
}
