//
//  FeedbackRequestModel.swift
//  Noonbody
//
//  Created by kong on 2022/01/27.
//

import Foundation

struct FeedbackRequestModel {
    let content: String
    let starRate: Int

    enum CodingKeys: String, CodingKey {
        case content
        case starRate = "star_rate"
    }
}
