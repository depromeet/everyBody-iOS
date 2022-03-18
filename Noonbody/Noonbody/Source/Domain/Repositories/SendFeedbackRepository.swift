//
//  SendFeedbackRepository.swift
//  Noonbody
//
//  Created by kong on 2022/03/18.
//

import Foundation

import RxSwift

protocol SendFeedbackRepository {
    func sendFeedback(request: FeedbackRequestModel) -> Observable<Int>
}
