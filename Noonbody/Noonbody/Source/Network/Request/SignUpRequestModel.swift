//
//  SignUpRequestModel.swift
//  Noonbody
//
//  Created by 윤예지 on 2021/12/11.
//

import Foundation

struct SignUpRequestModel {
    let password: String
    let device: Device
    let kind: String = "SIMPLE"
}

struct Device {
    let deviceToken: String
    let pushToken: String
    let deviceOS: String = "iOS"
}
